const std = @import("std");

const digits_map = std.ComptimeStringMap(i32, .{
    .{ "one", 1 },
    .{ "two", 2 },
    .{ "three", 3 },
    .{ "four", 4 },
    .{ "five", 5 },
    .{ "six", 6 },
    .{ "seven", 7 },
    .{ "eight", 8 },
    .{ "nine", 9 },
});

fn get_digits_2(line: []const u8) struct { i32, i32 } {
    var first: ?i32 = null;
    var last: ?i32 = null;
    var i: usize = 0;
    var tmp: usize = 0;

    while (i < line.len) : (i += 1) {
        tmp = i;

        if (std.ascii.isDigit(line[i])) {
            if (first == null) {
                first = @intCast(line[i] - '0');
            } else {
                last = @intCast(line[i] - '0');
            }
        }

        while (tmp <= line.len) : (tmp += 1) {
            if (digits_map.get(line[i..tmp])) |digit| {
                if (first == null) {
                    first = digit;
                } else {
                    last = digit;
                }
                break;
            }
        }
    }

    if (last == null) {
        last = first;
    }

    if (first == null) return .{ 0, 0 } else return .{ first.?, last.? };
}

fn get_digits(line: []const u8) struct { i32, i32 } {
    var first: ?i32 = null;
    var last: ?i32 = null;

    for (line) |char| {
        if (!std.ascii.isDigit(char)) continue;

        if (first == null) {
            first = @intCast(char - '0');
        } else {
            last = @intCast(char - '0');
        }
    }

    if (last == null) {
        last = first;
    }

    if (first == null) return .{ 0, 0 } else return .{ first.?, last.? };
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total: i32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const first, const last = get_digits_2(line);
        total += (first * 10) + last;
    }

    std.debug.print("Sum: {d}\n", .{total});
}

test "get digits part 1" {
    {
        var first, var last = get_digits("asds1dsd5");
        try std.testing.expectEqual(first, 1);
        try std.testing.expectEqual(last, 5);
    }
    {
        var first, var last = get_digits("asds1");
        try std.testing.expectEqual(first, 1);
        try std.testing.expectEqual(last, 1);
    }
    {
        var first, var last = get_digits("asds1dsa5dsada6");
        try std.testing.expectEqual(first, 1);
        try std.testing.expectEqual(last, 6);
    }
}

test "get digits part 2" {
    {
        var first, var last = get_digits_2("twofourthree");
        try std.testing.expect(first == 2);
        try std.testing.expect(last == 3);
    }
    {
        var first, var last = get_digits_2("fourtwoone");
        try std.testing.expect(first == 4);
        try std.testing.expect(last == 1);
    }
    {
        var first, var last = get_digits_2("ninesixeightseven");
        try std.testing.expect(first == 9);
        try std.testing.expect(last == 7);
    }
}
