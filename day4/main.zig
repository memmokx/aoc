const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const input = @embedFile("test.txt");

fn atoi(str: []const u8) usize {
    var v: usize = 0;
    var i: usize = 0;
    while (i < str.len and std.ascii.isWhitespace(str[i]))
        i += 1;
    while (i < str.len) : (i += 1) {
        if (!std.ascii.isDigit(str[i]))
            break;
        v *= 10;
        v += str[i] - '0';
    }
    return v;
}
const start = "Card ";

pub fn main() !void {
    defer arena.deinit();
    var iterator = std.mem.tokenizeSequence(u8, input, "\n");

    var p1: usize = 0;
    while (iterator.next()) |line| {
        var winning_numbers = std.AutoHashMap(usize, void).init(allocator);
        var split = std.mem.split(u8, line[8..], " | ");
        var w = std.mem.tokenizeSequence(u8, split.next() orelse unreachable, " ");
        while (w.next()) |num| try winning_numbers.put(atoi(num), {});
        var turn = std.mem.tokenizeSequence(u8, split.next() orelse unreachable, " ");
        var points: usize = 0;
        while (turn.next()) |t| {
            if (winning_numbers.get(atoi(t)) != null) {
                if (points == 0) points = 1 else points *= 2;
            }
        }
        p1 += points;
    }
    std.debug.print("part1: {d}\n", .{p1});
}
