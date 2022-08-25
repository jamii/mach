//! Ensures that standard files in subprojects, like LICENSE files, .gitattributes, etc.
//! are present and in-sync with the version in dev/template.
//!
//! Usage: zig run ./dev/ensure-standard-files.zig

const std = @import("std");

const projects = [_][]const u8{
    ".",
    "basisu",
    "ecs",
    "freetype",
    "gamemode",
    "glfw",
    "gpu",
    "gpu-dawn",
    "sysaudio",
    "sysjs",
};

pub fn main() !void {
    inline for (projects) |project| {
        copyFile("dev/template/LICENSE", project ++ "/LICENSE");
        copyFile("dev/template/LICENSE-MIT", project ++ "/LICENSE-MIT");
        copyFile("dev/template/LICENSE-APACHE", project ++ "/LICENSE-APACHE");
        copyFile("dev/template/.gitattributes", project ++ "/.gitattributes");
        copyFile("dev/template/.gitignore", project ++ "/.gitignore");

        if (!std.mem.eql(u8, project, ".")) {
            copyFile(
                "dev/template/.github/pull_request_template.md",
                project ++ "/.github/pull_request_template.md",
            );
            replaceInFile(project ++ "/.github/pull_request_template.md", "foobar", project);
        }
        copyFile("dev/template/.github/FUNDING.yml", project ++ "/.github/FUNDING.yml");
    }
}

pub fn copyFile(src_path: []const u8, dst_path: []const u8) void {
    std.fs.cwd().makePath(std.fs.path.dirname(dst_path).?) catch unreachable;
    std.fs.cwd().copyFile(src_path, std.fs.cwd(), dst_path, .{}) catch unreachable;
}

pub fn replaceInFile(file_path: []const u8, needle: []const u8, replacement: []const u8) void {
    const allocator = std.heap.page_allocator;
    const data = std.fs.cwd().readFileAlloc(allocator, file_path, std.math.maxInt(usize)) catch unreachable;
    const new_data = std.mem.replaceOwned(u8, allocator, data, needle, replacement) catch unreachable;
    std.fs.cwd().writeFile(file_path, new_data) catch unreachable;
}