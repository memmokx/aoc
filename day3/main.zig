const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const input = @embedFile("input.txt");

const Symbol = struct {
    row: usize,
    col: usize,
    char: u8,
};

const Number = struct {
    row: usize,
    start: usize,
    end: usize,
    number: usize,
};

pub fn main() !void {
    defer arena.deinit();
    var line_number: usize = 0;
    var iterator = std.mem.tokenizeSequence(u8, input, "\n");
    var symbol = std.ArrayList(Symbol).init(allocator);
    var number = std.ArrayList(Number).init(allocator);

    while (iterator.next()) |line| : (line_number += 1) {
        var col: usize = 0;
        while (col < line.len) {
            const char = line[col];
            if (char != '.' and !std.ascii.isDigit(char)) {
                try symbol.append(.{ .row = line_number, .col = col, .char = char });
            }
            if (std.ascii.isDigit(char)) {
                var start = col;
                var v: usize = 0;
                while (col < line.len and std.ascii.isDigit(line[col])) : (col += 1) {
                    v *= 10;
                    v += line[col] - '0';
                }
                var end = col;
                try number.append(.{ .row = line_number, .start = start, .end = end, .number = v });
                continue;
            }
            col += 1;
        }
    }

    var numbers = try number.toOwnedSlice();
    var symbols = try symbol.toOwnedSlice();

    var total: usize = 0;
    for (numbers) |num| {
        if (hasAdjacentSymbol(num, symbols)) {
            total += num.number;
        }
    }

    std.debug.print("part 1: {d}\n", .{total});

    var gears: usize = 0;
    for (symbols) |sym| {
        if (sym.char == '*') {
            gears += getGear(sym, numbers) orelse continue;
        }
    }
    std.debug.print("part 2; {d}", .{gears});
}

fn hasAdjacentSymbol(number: Number, symbols: []Symbol) bool {
    for (symbols) |symbol| {
        if ((symbol.row > number.row + 1)) {
            continue;
        }
        if (number.row != 0 and symbol.row < number.row - 1) {
            continue;
        }
        if (isAdjacent(symbol, number)) {
            return true;
        }
    }

    return false;
}

fn isAdjacent(symbol: Symbol, number: Number) bool {
    var start = if (number.start == 0) number.start else number.start - 1;
    var end = number.end;
    if ((symbol.row > number.row + 1)) {
        return false;
    }
    if (number.row != 0 and symbol.row < number.row - 1) {
        return false;
    }
    return (symbol.col >= start and symbol.col <= end);
}

fn getGear(symbol: Symbol, numbers: []Number) ?usize {
    var i: usize = 0;
    var r: [2]Number = undefined;
    var idx: usize = 0;
    while (i < numbers.len and idx < 2) {
        if (isAdjacent(symbol, numbers[i])) {
            r[idx] = numbers[i];
            idx += 1;
        }
        i += 1;
    }
    if (idx != 2)
        return null;
    return r[0].number * r[1].number;
}