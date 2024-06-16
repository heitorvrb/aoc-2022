const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const expect = std.testing.expect;

/// A nice alternate solution I found on reddit: https://www.reddit.com/r/adventofcode/comments/zac2v2/comment/j39n4le/
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

    var score_pt1: u32 = 0;
    var score_pt2: u32 = 0;

    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();

        const opponent: i16 = line.items[0];
        const me: i16 = line.items[2];

        score_pt1 += line.items[2] - 'X' + 1;
        const delta_pt1 = @mod(me - opponent - 23 + 3, 3);
        if (delta_pt1 == 1) {
            score_pt1 += 6;
        } else if (delta_pt1 == 0) {
            score_pt1 += 3;
        }

        var delta_pt2 = @abs(@mod(me + opponent - 128 - 25, 3));
        if (delta_pt2 == 0) {
            delta_pt2 = 3;
        }
        score_pt2 += delta_pt2 + (line.items[2] - 'X') * 3;
    } else |err| switch (err) {
        error.EndOfStream => {}, // Last line (empty line), don't do anything
        else => return err, // Propagate error
    }

    print("RESULT pt1: {}\nRESULT pt2: {}\n", .{ score_pt1, score_pt2 });
}
