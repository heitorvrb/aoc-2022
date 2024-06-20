const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const expect = std.testing.expect;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = try fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();
    const writer = line.writer();

    var totalPriorities: u32 = 0;

    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();

        const middle = line.items.len / 2;
        // print("{}\n", .{middle});

        const firstHalf = line.items[0..middle];
        const secondHalf = line.items[middle..];
        // print("firstHalf: {s} secondHalf: {s}\n", .{ firstHalf, secondHalf });

        outer: for (firstHalf) |item| {
            for (secondHalf) |secondHalfItem| {
                if (item == secondHalfItem) {
                    // print("found! {c}({}) priority: {}\n", .{ item, item, getPriority(item) });
                    totalPriorities += getPriority(item);
                    break :outer;
                }
            }
        }
    } else |err| switch (err) {
        error.EndOfStream => {}, // Last line (empty line), don't do anything
        else => return err, // Propagate error
    }

    print("Total priorities: {}\n\n", .{totalPriorities});
}

fn getPriority(item: u8) u8 {
    return switch (item) {
        'A'...'Z' => item - 38,
        'a'...'z' => item - 96,
        else => unreachable,
    };
}

test "getPriority" {
    try expect(getPriority('a') == 1);
    try expect(getPriority('z') == 26);

    try expect(getPriority('A') == 27);
    try expect(getPriority('Z') == 52);
}
