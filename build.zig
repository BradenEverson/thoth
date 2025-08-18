const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const thoth_mod = b.addModule("thoth", .{
        .root_source_file = b.path("src/thoth.zig"),
        .target = target,
        .optimize = optimize,
    });

    const unit_tests = b.addTest(.{
        .root_module = thoth_mod,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run the unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const coop = b.addExecutable(.{
        .name = "cooperative",
        .root_source_file = b.path("examples/cooperative.zig"),
        .target = b.graph.host,
    });

    coop.root_module.addImport("thoth", thoth_mod);

    b.installArtifact(coop);

    const coop_cmd = b.addRunArtifact(coop);
    coop_cmd.step.dependOn(b.getInstallStep());

    const coop_step = b.step("coop", "Run the sample cooperative scheduler");
    if (b.args) |args| {
        coop_cmd.addArgs(args);
    }

    coop_step.dependOn(&coop_cmd.step);

    const preemptive = b.addExecutable(.{
        .name = "preemptive",
        .root_source_file = b.path("examples/preemptive.zig"),
        .target = b.graph.host,
    });

    preemptive.root_module.addImport("thoth", thoth_mod);

    b.installArtifact(coop);

    const preempt_cmd = b.addRunArtifact(preemptive);
    coop_cmd.step.dependOn(b.getInstallStep());

    const preempt_step = b.step("preempt", "Run the sample preemptive scheduler");
    if (b.args) |args| {
        preempt_cmd.addArgs(args);
    }

    preempt_step.dependOn(&preempt_cmd.step);
}
