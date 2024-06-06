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
    var elvesCarryingTheMost = [_]u32{ 0, 0, 0 };

    var eof = false;
    while (!eof) {
        // Read line
        reader.streamUntilDelimiter(writer, '\n', null) catch |err| switch (err) {
            error.EndOfStream => eof = true,
            else => return err,
        };
        defer line.clearRetainingCapacity();

        print("--{s}\n", .{line.items});

        if (line.items.len > 0) {
            const calories = try fmt.parseInt(u32, line.items, 10);
            print("{d}\n", .{calories});
            currentElf += calories;
        } else {
            for (&elvesCarryingTheMost, 0..elvesCarryingTheMost.len) |*elf, index| {
                if (currentElf > elf.*) {
                    //Shift other elfs to keep it ordered
                    var i = elvesCarryingTheMost.len - 1;
                    while (i > index) : (i -= 1) {
                        elvesCarryingTheMost[i] = elvesCarryingTheMost[i - 1];
                    }
                    elf.* = currentElf;
                    break;
                }
            }
            printElves(&elvesCarryingTheMost);
            currentElf = 0;
        }
    }

    const result = sumElves(&elvesCarryingTheMost);
    print("{}\n", .{result});
}

fn printElves(elves: []u32) void {
    for (elves, 0..) |elf, i| {
        print("elf{d}: {} | ", .{ i, elf });
    }
    print("\n", .{});
}

fn sumElves(elves: []u32) u32 {
    var sum: u32 = 0;
    for (elves) |elf| {
        sum += elf;
    }
    return sum;
}
