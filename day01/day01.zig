const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const fmt = std.fmt;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = try fs.cwd().openFile("input-test.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();
    const writer = line.writer();

    var currentElf: u32 = 0;
    var elfCarryingTheMost: u32 = 0;

    var eof = false;
    while (!eof) {
        // Read line
        reader.streamUntilDelimiter(writer, '\n', null) catch |err| switch (err) {
            error.EndOfStream => eof = true,
            else => return err,
        };
        defer line.clearRetainingCapacity();

        print("--{s}\n", .{line.items});

        if (line.items.len == 0) {
            if (currentElf > elfCarryingTheMost) elfCarryingTheMost = currentElf;
            currentElf = 0;
            continue;
        }

        const calories = try fmt.parseInt(u32, line.items, 10);
        print("{d}\n", .{calories});
        currentElf += calories;
    }

    print("RESULT: {}\n", .{elfCarryingTheMost});
}
