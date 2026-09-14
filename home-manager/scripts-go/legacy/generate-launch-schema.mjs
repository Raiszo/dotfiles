#!/usr/bin/env node
import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

/** @typedef {null | boolean | number | string | JsonValue[] | { [key: string]: JsonValue }} JsonValue */
/** @typedef {{ [key: string]: JsonValue }} JsonObject */

/**
 * Require an object before inspecting a manifest or schema fragment.
 * @param {JsonValue | undefined} value
 * @param {string} label
 * @returns {JsonObject}
 */
function object(value, label) {
	if (value === null || typeof value !== "object" || Array.isArray(value)) {
		throw new Error(`Expected an object: ${label}`);
	}
	return value;
}

/**
 * Resolve whole-string %key% placeholders, preserving JSON value types.
 * Replacement messages are literal text, not further localization keys.
 * @param {JsonValue} value
 * @param {JsonObject} translations
 * @returns {JsonValue}
 */
function localize(value, translations) {
	if (typeof value === "string") {
		const match = /^%([^%]+)%$/.exec(value);
		if (!match) return value;
		const entry = Object.hasOwn(translations, match[1])
			? translations[match[1]] : undefined;
		const message = typeof entry === "string" ? entry
			: entry && typeof entry === "object" && !Array.isArray(entry)
				? entry.message : undefined;
		if (typeof message !== "string") {
			console.warn(`Missing translation (preserved): ${value}`);
			return value;
		}
		return message;
	}
	if (Array.isArray(value)) return value.map((item) => localize(item, translations));
	if (value !== null && typeof value === "object") {
		return Object.fromEntries(Object.entries(value).map(
			([key, item]) => [key, localize(item, translations)],
		));
	}
	return value;
}

/**
 * Build a personal launch.json schema from one exact extension release.
 * @param {JsonObject} manifest Parsed extension package.json.
 * @param {JsonObject} translations Parsed default package.nls.json.
 * @returns {JsonObject}
 */
export function generateSchema(manifest, translations) {
	const adapterType = "stlinkgdbtarget";
	const debuggers = object(manifest.contributes, "contributes").debuggers;
	if (!Array.isArray(debuggers)) throw new Error("Missing debugger contributions");
	const matches = debuggers.map((entry) => object(entry, "debugger"))
		.filter((entry) => entry.type === adapterType);
	if (matches.length !== 1) throw new Error(`Expected exactly one ${adapterType} debugger`);
	const attributes = object(localize(
		object(matches[0].configurationAttributes, "configurationAttributes"), translations,
	), "localized configurationAttributes");

	for (const key of ["publisher", "name", "version"]) {
		if (typeof manifest[key] !== "string") throw new Error(`Missing manifest ${key}`);
	}

	/** @type {JsonObject} */
	const commonProperties = {
		name: { type: "string" },
		type: { type: "string" },
		request: { type: "string" },
		"dap-compilation": {
			type: "string", description: "Command to run before starting the debug session.",
		},
		"dap-compilation-dir": {
			type: "string", description: "Working directory for the compilation command.",
		},
	};

	/** @param {string} request @returns {JsonObject} */
	function configurationSchema(request) {
		const source = object(attributes[request], `${request} schema`);
		const properties = object(source.properties, `${request} properties`);
		const required = source.required ?? [];
		if (!Array.isArray(required) || required.some((key) => typeof key !== "string")) {
			throw new Error(`Invalid required array for ${request}`);
		}
		return {
			...source,
			type: "object",
			properties: {
				...properties,
				...commonProperties,
				type: { const: adapterType },
				request: { const: request },
			},
			required: [...new Set(["name", "type", "request", ...required])],
		};
	}

	return {
		$schema: "http://json-schema.org/draft-07/schema#",
		title: `Emacs launch.json — ${manifest.name} ${manifest.version}`,
		$comment: `Generated from ${manifest.publisher}.${manifest.name}@${manifest.version}`,
		type: "object",
		properties: {
			version: { type: "string", default: "0.2.0" },
			configurations: {
				type: "array",
				items: {
					type: "object",
					properties: commonProperties,
					required: ["name", "type", "request"],
					if: {
						properties: { type: { const: adapterType } },
						required: ["type"],
					},
					then: { oneOf: [configurationSchema("launch"), configurationSchema("attach")] },
				},
			},
		},
	};
}

if (import.meta.main) {
	const [extensionDir, outputFile, ...extra] = process.argv.slice(2);
	if (!extensionDir || !outputFile || extra.length) {
		throw new Error("Usage: node generate-launch-schema.mjs EXTENSION_DIR OUTPUT_FILE");
	}
	/** @param {string} name @returns {Promise<JsonObject>} */
	async function readJson(name) {
		return object(JSON.parse(await readFile(join(extensionDir, name), "utf8")), name);
	}
	const schema = generateSchema(await readJson("package.json"), await readJson("package.nls.json"));
	await writeFile(outputFile, `${JSON.stringify(schema, null, 2)}\n`);
}
