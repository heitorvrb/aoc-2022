const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const expect = std.testing.expect;

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

    var totalResults: u32 = 0;

    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();

        const opponent = try charToMove(line.items[0]);
        const outcome = try charToOutcome(line.items[2]);
        totalResults += playRound(opponent, outcome);
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
        'A' => Move.rock,
        'B' => Move.paper,
        'C' => Move.scissors,
        else => return error.InvalidMove,
    };
}

fn charToOutcome(char: u8) !Outcome {
    return switch (char) {
        'X' => Outcome.loss,
        'Y' => Outcome.draw,
        'Z' => Outcome.win,
        else => return error.InvalidOutcome,
    };
}

fn playRound(opponent: Move, outcome: Outcome) u8 {
    const me = switch (opponent) {
        Move.rock => switch (outcome) {
            Outcome.loss => Move.scissors,
            Outcome.draw => Move.rock,
            Outcome.win => Move.paper,
        },
        Move.paper => switch (outcome) {
            Outcome.loss => Move.rock,
            Outcome.draw => Move.paper,
            Outcome.win => Move.scissors,
        },
        Move.scissors => switch (outcome) {
            Outcome.loss => Move.paper,
            Outcome.draw => Move.scissors,
            Outcome.win => Move.rock,
        },
    };

    return @intFromEnum(me) + @intFromEnum(outcome);
}

test "playRound all cases" {
    try expect(playRound(Move.rock, Outcome.loss) == 0 + 3);
    try expect(playRound(Move.rock, Outcome.draw) == 3 + 1);
    try expect(playRound(Move.rock, Outcome.win) == 6 + 2);

    try expect(playRound(Move.paper, Outcome.loss) == 0 + 1);
    try expect(playRound(Move.paper, Outcome.draw) == 3 + 2);
    try expect(playRound(Move.paper, Outcome.win) == 6 + 3);

    try expect(playRound(Move.scissors, Outcome.loss) == 0 + 2);
    try expect(playRound(Move.scissors, Outcome.draw) == 3 + 3);
    try expect(playRound(Move.scissors, Outcome.win) == 6 + 1);
}
