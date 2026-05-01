import { buildModule } from "@nomicfoundation/ignition-core";

export const ArgumentationModule = buildModule("ArgumentationModule", (m) => {
  const argumentation = m.contract("Argumentation");
  return { argumentation };
});