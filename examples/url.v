module main

import qrv

fn main() {
    qrcode := qrv.new_code(4, 3, 10)
                 .encode_string('https://google.com')
                 .str()
    println(qrcode)
}