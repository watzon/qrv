module qrv

#flag -lqrencode

#include <qrencode.h>

struct C.QRcode {
mut:
    version int
    width int
    data byteptr
}

struct Code {
mut:
    version int
    level int
    margin int
    width int
    data byteptr
}

// Error correction level for the code.
// @see https://www.wikiwand.com/en/QR_code#/Error_correction
enum Level {
    Low
    Medium
    Quartile
    High
}

fn C.QRcode_encodeString8bit(str string, version int, level int) *QRcode
fn C.QRcode_encodeString(str string, version int, level int, mode int, casesensitive int) *QRcode
fn C.QRcode_encodeStringMQR(str string, version int, level int, mode int, casesensitive int) *QRcode
fn C.QRcode_encodeString8bitMQR(str string, version int, level int) *QRcode

pub fn new_code(version int, level int, margin int) Code {
    return Code{ version: version, level: level, margin: margin }
}

pub fn (qr Code) encode_string(str string) Code {
    mut code := C.QRcode_encodeString8bit(str.cstr(), qr.version, int(qr.level))

    qr.width = code.width
    qr.data = code.data
    return qr
}

pub fn (qr Code) str() string {
    margin := qr.margin
    realwidth := qr.width + (margin * 2)
    empty := ' '
    lowhalf := '\342\226\204'
    uphalf := '\342\226\200'
    full := '\342\226\210'
    mut builder := ''

    // Print the top margin
    for i := 0; i < (margin / 2); i++ {
        for j := 0; j < realwidth; j++ {
            builder = builder + full
        }

        builder = builder + '\n'
    }

    for y := 0; y < qr.width; y++ {
        top := (y % 2) == 0
        
        if !top {
            continue
        }

        row1 := qr.data + y * qr.width
        row2 := row1 + qr.width

        // Print the left margin
        for i := 0; i < margin; i++ {
            builder = builder + full
        }

        // Print the encoded data
        for x := 0; x < qr.width; x++ {
            if (row1[x] & 1) == 0 {
                if top && (row2[x] & 1) == 0 {
                    builder = builder + full 
                } else {
                    builder = builder + uphalf
                }
            } else if top && (row2[x] & 1) == 0 {
                builder = builder + lowhalf
            } else {
                builder = builder + empty
            }
        }

        // Print the right margin
        for i := 0; i < margin; i++ {
            builder = builder + full
        }

        builder = builder + '\n'
    }

    for i := 0; i < (margin / 2); i++ {
        for j := 0; j < realwidth; j++ {
            builder = builder + full
        }

        builder = builder + '\n'
    }

    return builder
}