const std = @import("std");
const pr = std.debug.print;
const fs = std.fs;
const http = std.http;
const allocator = std.heap.page_allocator;

const sesh = @embedFile("session.txt");

pub fn main() !void {
    var splits = std.mem.split(u8, sesh, "\n");
    var session = splits.first();

    pr("[Day 3]", .{});

    var client = http.Client{
        .allocator = allocator,
    };

    const uri = try std.Uri.parse("https://adventofcode.com/2015/day/3/input");
    var headers = http.Headers{
        .allocator = allocator,
        .owned = false
    };
    try headers.append("accept", "*/*");
    var cookie_str = try std.fmt.allocPrint(allocator, "session={s}", .{session});
    try headers.append("cookie", cookie_str);

    var req = try client.request(.GET, uri, headers, .{});
    defer req.deinit();

    try req.start();
    try req.wait();

    const body = req.reader().readAllAlloc(allocator, 8192) catch unreachable;
    defer allocator.free(body);

    var input_filename = "day03_input.txt";
    var file = try fs.cwd().createFile(input_filename, .{});
    defer file.close();
    try file.writeAll(body);

    pr("input data written to file {s}", .{input_filename});


}
