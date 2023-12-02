const std = @import("std");

const Color = enum { red, green, blue };

const color_map = std.ComptimeStringMap(Color, .{
    .{ "green", .green },
    .{ "red", .red },
    .{ "blue", .blue },
});

const Round = struct {
    const Entry = struct {
        color: Color,
        revealed: i32,
    };
    data: []Entry,

    pub fn deinit(self: Round, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }
};

const Game = struct {
    id: i32 = 0,
    rounds: []Round,

    pub fn deinit(self: Game, allocator: std.mem.Allocator) void {
        for (self.rounds) |round| {
            round.deinit(allocator);
        }
        allocator.free(self.rounds);
    }

    pub fn is_possible(game: Game, limits: Sum) bool {
        for (game.rounds) |round| {
            var sum: Sum = .{};
            for (round.data) |entry| {
                switch (entry.color) {
                    .red => sum.red += entry.revealed,
                    .green => sum.green += entry.revealed,
                    .blue => sum.blue += entry.revealed,
                }
            }
            if ((sum.red > limits.red) or (sum.green > limits.green) or (sum.blue > limits.blue)) {
                return false;
            }
        }

        return true;
    }

    pub fn get_power(game: Game) i32 {
        var sum: Sum = .{};
        for (game.rounds) |round| {
            for (round.data) |entry| {
                switch (entry.color) {
                    .red => {
                        if (sum.red < entry.revealed)
                            sum.red = entry.revealed;
                    },
                    .blue => {
                        if (sum.blue < entry.revealed)
                            sum.blue = entry.revealed;
                    },
                    .green => {
                        if (sum.green < entry.revealed)
                            sum.green = entry.revealed;
                    },
                }
            }
        }

        return (sum.red * sum.green * sum.blue);
    }
};

fn atoi(str: []const u8) i32 {
    var v: i32 = 0;

    for (str) |char| {
        if (!std.ascii.isDigit(char)) break;
        v *= 10;
        v += char - '0';
    }

    return v;
}

fn parse_round(allocator: std.mem.Allocator, line: []const u8) !Round {
    var entries = std.ArrayList(Round.Entry).init(allocator);
    defer entries.deinit();
    var iterator = std.mem.splitSequence(u8, line, ", ");

    while (iterator.next()) |entry| {
        var split = std.mem.splitSequence(u8, entry, " ");
        var revealed = atoi(split.next() orelse return error.MalformedLine);
        var color = color_map.get(split.next() orelse return error.MalformedLine) orelse return error.UnknownColor;

        try entries.append(.{ .revealed = revealed, .color = color });
    }

    return .{ .data = try entries.toOwnedSlice() };
}

fn parse_game(allocator: std.mem.Allocator, line: []const u8) !Game {
    var start = std.mem.indexOf(u8, line, ": ") orelse return error.MalformedLine;
    var iterator = std.mem.splitSequence(u8, line[start + 2 ..], "; ");
    var rounds = std.ArrayList(Round).init(allocator);
    defer rounds.deinit();

    while (iterator.next()) |round| {
        try rounds.append(try parse_round(allocator, round));
    }

    var idx = std.mem.indexOf(u8, line, "Game ") orelse return error.MalformedLine;

    return .{ .id = atoi(line[idx + 5 ..]), .rounds = try rounds.toOwnedSlice() };
}

const Sum = struct {
    red: i32 = 0,
    green: i32 = 0,
    blue: i32 = 0,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var vec = std.ArrayList(Game).init(allocator);
    defer vec.deinit();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try vec.append(try parse_game(allocator, line));
    }

    var total: i32 = 0;
    const games = try vec.toOwnedSlice();
    defer allocator.free(games);

    const limits: Sum = .{ .red = 12, .green = 13, .blue = 14 };
    _ = limits;
    for (games) |game| {
        // Part 1
        // if (game.is_possible(limits)) {
        //     total += game.id;
        // }
        total += game.get_power();
        game.deinit(allocator);
    }

    std.debug.print("{d}", .{total});
}
