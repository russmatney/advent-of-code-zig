const std = @import("std");
const pr = std.debug.print;
const fs = std.fs;
const http = std.http;
const allocator = std.heap.page_allocator;

const sesh = @embedFile("session.txt");

const max_bytes = 32568;

pub fn fetch_input(filename: []const u8, year: []const u8, day: []const u8) ![]const u8 {
    var splits = std.mem.split(u8, sesh, "\n");
    var session = splits.first();

    var client = http.Client{
        .allocator = allocator,
    };

    var uri_str = try std.fmt.allocPrint(allocator, "https://adventofcode.com/{s}/day/{s}/input", .{year, day});
    const uri = try std.Uri.parse(uri_str);
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

    // TODO how to read all bytes here?
    const body = req.reader().readAllAlloc(allocator, max_bytes) catch |err| {
        pr("error reading request body {any}\n", .{err});
        switch (err) {
            else => return err
        }
    };

    var file = try fs.cwd().createFile(filename, .{});
    defer file.close();
    try file.writeAll(body);

    pr("input data written to file {s}\n", .{filename});
    return body;
}

pub fn input_data(year: []const u8, day: []const u8) ![]const u8 {
    var input_file = try std.fmt.allocPrint(allocator, "day{s}_input.txt", .{day});

    var file = fs.cwd().openFile(input_file, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            pr("Input file not found, fetching...\n", .{});
            var data = try fetch_input(input_file, year, day);
            return data;
        },
        else => return err
    };
    defer file.close();
    pr("Input file found, continuing...\n", .{});

    var data = file.readToEndAlloc(allocator, max_bytes) catch |err| {
        switch (err) {
            error.FileTooBig => {
                pr("Max Bytes read! Bump this allocator a bit!\n", .{});
                return err;
            },
            else => return err
        }
    };

    // defer allocator.free(data);

    return data;
}
