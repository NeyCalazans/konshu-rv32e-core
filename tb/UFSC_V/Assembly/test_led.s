.text
.globl main

main:
    # 1. Load MMIO base address (0x00007F00)
    li   t0, 0x00007F00

    # 2. Full word store test (sw)
    # Turn on alternating pattern 01010101 on lower LEDs
    li   t1, 0x0055
    sw   t1, 0(t0)          # leds should become 0x0055

    # 3. Invert pattern to 10101010
    li   t1, 0x00AA
    sw   t1, 0(t0)          # leds should become 0x00AA

    # 4. Turn on all 16 LEDs
    li   t1, 0xFFFF
    sw   t1, 0(t0)          # leds should become 0xFFFF

    # 5. Byte store test (sb):
    # Update lower 8 LEDs only to 0x12
    li   t1, 0x12
    sb   t1, 0(t0)          # leds should become 0xFF12

    # Update upper 8 LEDs only (offset 1) to 0x34
    li   t1, 0x34
    sb   t1, 1(t0)          # leds should become 0x3412

    # 6. Word load test (lw):
    # Read current LED state back into register t2
    lw   t2, 0(t0)          # t2 should receive 0x00003412

end:
    j end                   # Infinite loop to halt execution
