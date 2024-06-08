const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const fmt = std.fmt;
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

    var totalResults: u32 = 0;

    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();

        const opponent = try charToMove(line.items[0]);
        const me = try charToMove(line.items[2]);
        totalResults += playRound(opponent, me);
    } else |err| switch (err) {
        error.EndOfStream => {}, // Last line (empty line), don't do anything
        else => return err, // Propagate error
    }

    print("RESULT: {}\n", .{totalResults});
}

const Move = enum(u8) {
    rock = 1,
    paper = 2,
    scissors = 3,
};

const Outcome = enum(u8) {
    loss = 0,
    draw = 3,
    win = 6,
};

fn charToMove(char: u8) !Move {
    return switch (char) {
        'A', 'X' => Move.rock,
        'B', 'Y' => Move.paper,
        'C', 'Z' => Move.scissors,
        else => return error.InvalidMove,
    };
}

fn playRound(opponent: Move, me: Move) u8 {
    const outcome = switch (opponent) {
        Move.rock => switch (me) {
            Move.rock => Outcome.draw,
            Move.paper => Outcome.win,
            Move.scissors => Outcome.loss,
        },
        Move.paper => switch (me) {
            Move.rock => Outcome.loss,
            Move.paper => Outcome.draw,
            Move.scissors => Outcome.win,
        },
        Move.scissors => switch (me) {
            Move.rock => Outcome.win,
            Move.paper => Outcome.loss,
            Move.scissors => Outcome.draw,
        },
    };

    return @intFromEnum(me) + @intFromEnum(outcome);
}

test "playRound all cases" {
    try expect(playRound(Move.rock, Move.rock) == 3 + 1);
    try expect(playRound(Move.rock, Move.paper) == 6 + 2);
    try expect(playRound(Move.rock, Move.scissors) == 0 + 3);

    try expect(playRound(Move.paper, Move.rock) == 0 + 1);
    try expect(playRound(Move.paper, Move.paper) == 3 + 2);
    try expect(playRound(Move.paper, Move.scissors) == 6 + 3);

    try expect(playRound(Move.scissors, Move.rock) == 6 + 1);
    try expect(playRound(Move.scissors, Move.paper) == 0 + 2);
    try expect(playRound(Move.scissors, Move.scissors) == 3 + 3);
}
