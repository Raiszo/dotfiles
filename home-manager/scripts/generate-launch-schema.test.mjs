import assert from "node:assert/strict";
import { test } from "node:test";
import { generateSchema } from "./generate-launch-schema.mjs";

/** Build a fixture with localization and JSON values that must survive extraction. */
function fixture() {
  return {
    publisher: "STMicroelectronics", name: "test-adapter", version: "1.4.0",
    contributes: { debuggers: [{
      type: "stlinkgdbtarget",
      configurationAttributes: {
        launch: {
          required: ["program"], additionalProperties: false,
          properties: {
            program: { type: "string", description: "%program%" },
            enabled: { type: "boolean", default: false },
            commands: { type: "array", default: [] },
            optional: { default: null },
            mode: { enum: ["%mode%"], default: "%mode%" },
          },
        },
        attach: { properties: { port: { type: "number" } } },
      },
    }] },
  };
}

test("localizes nested strings and preserves constraints and JSON types", () => {
  const schema = generateSchema(fixture(), {
    program: "Executable", mode: { message: "auto" },
  });
  const launch = schema.properties.configurations.items.then.oneOf[0];
  assert.equal(launch.properties.program.description, "Executable");
  assert.deepEqual(launch.properties.mode, { enum: ["auto"], default: "auto" });
  assert.equal(launch.properties.enabled.default, false);
  assert.equal(launch.properties.optional.default, null);
  assert.deepEqual(launch.properties.commands.default, []);
  assert.deepEqual(launch.required, ["name", "type", "request", "program"]);
  assert.equal(launch.additionalProperties, false);
  assert.equal(launch.properties["dap-compilation"].type, "string");
  assert.match(schema.$comment, /test-adapter@1\.4\.0/);
});

test("fails on missing request schemas", () => {
  const manifest = fixture();
  delete manifest.contributes.debuggers[0].configurationAttributes.attach;
  assert.throws(() => generateSchema(manifest, { program: "Executable", mode: "auto" }),
    /attach schema/);
});

test("warns about missing translations without changing their values", (t) => {
  const warn = t.mock.method(console, "warn", () => {});
  const schema = generateSchema(fixture(), { mode: "auto" });
  assert.equal(schema.properties.configurations.items.then.oneOf[0]
    .properties.program.description, "%program%");
  assert.equal(warn.mock.callCount(), 1);
});
