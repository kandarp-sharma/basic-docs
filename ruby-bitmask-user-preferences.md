# Ruby Bitmask: User Preferences

This example uses **bitwise flags** to store multiple user preferences inside a single integer.

```ruby
PREFERENCES = {
  1 => "sms",
  2 => "whatsapp",
  4 => "email",
  8 => "call"
}

def get_user_preferences(user_preferences)
  whitelist_preferences = user_preferences.to_s(2)
                                            .split("")
                                            .reverse
                                            .map.with_index { |v, i| 2**i if v == "1" }
                                            .compact

  user_preference = whitelist_preferences.map { |i| PREFERENCES[i] }

  puts "#{user_preference}"
end

get_user_preferences(15)
```

---

## 1. What is the idea?

Each preference is assigned a **power of 2**:

| Value | Preference | Binary |
|---:|---|---:|
| `1` | SMS | `0001` |
| `2` | WhatsApp | `0010` |
| `4` | Email | `0100` |
| `8` | Call | `1000` |

Because each value uses a different binary bit, we can combine multiple preferences by adding them.

For example:

```ruby
1 + 2 + 4 + 8
# => 15
```

Binary representation:

```text
15 = 1111
```

Every bit is `1`, meaning **all four preferences are enabled**.

---

# 2. The `PREFERENCES` Hash

```ruby
PREFERENCES = {
  1 => "sms",
  2 => "whatsapp",
  4 => "email",
  8 => "call"
}
```

This maps the numeric bit values to human-readable preference names.

For example:

```ruby
PREFERENCES[1]
# => "sms"

PREFERENCES[4]
# => "email"

PREFERENCES[8]
# => "call"
```

---

# 3. Converting the Number to Binary

The first interesting part is:

```ruby
user_preferences.to_s(2)
```

Ruby's `Integer#to_s(2)` converts an integer to its binary representation.

Examples:

```ruby
1.to_s(2)
# => "1"

2.to_s(2)
# => "10"

4.to_s(2)
# => "100"

8.to_s(2)
# => "1000"

15.to_s(2)
# => "1111"
```

So:

```ruby
15.to_s(2)
# => "1111"
```

---

# 4. Splitting the Binary String

```ruby
"1111".split("")
# => ["1", "1", "1", "1"]
```

Now every binary digit is represented as an individual element.

---

# 5. Reversing the Bits

```ruby
["1", "1", "1", "1"].reverse
# => ["1", "1", "1", "1"]
```

With `15`, reversing doesn't visibly change anything because all bits are `1`.

But consider `5`:

```ruby
5.to_s(2)
# => "101"

"101".split("").reverse
# => ["1", "0", "1"]
```

Reversing is important because the code uses the index to calculate the corresponding power of 2.

The indexes become:

```text
index:  0  1  2
bit:    1  0  1
```

Therefore:

```text
index 0 → 2⁰ → 1
index 1 → 2¹ → 2
index 2 → 2² → 4
```

---

# 6. `map.with_index`

This part:

```ruby
.map.with_index { |v, i| 2**i if v == "1" }
```

checks every bit.

If the bit is `"1"`, it calculates:

```ruby
2**i
```

For example:

```text
bit = 1
index = 0

2**0
# => 1
```

And:

```text
bit = 1
index = 2

2**2
# => 4
```

For `5`:

```ruby
5.to_s(2)
# => "101"
```

After reversing:

```ruby
["1", "0", "1"]
```

The calculation becomes:

```text
index 0 → "1" → 2⁰ → 1
index 1 → "0" → ignored
index 2 → "1" → 2² → 4
```

Result before `compact`:

```ruby
[1, nil, 4]
```

---

# 7. `compact`

```ruby
.compact
```

removes `nil` values.

So:

```ruby
[1, nil, 4].compact
# => [1, 4]
```

Therefore, for:

```ruby
get_user_preferences(5)
```

the calculated preference values are:

```ruby
[1, 4]
```

---

# 8. Converting Values to Preference Names

Next:

```ruby
whitelist_preferences.map { |i| PREFERENCES[i] }
```

For:

```ruby
[1, 4]
```

Ruby performs:

```ruby
PREFERENCES[1]
# => "sms"

PREFERENCES[4]
# => "email"
```

So the final result is:

```ruby
["sms", "email"]
```

---

# 9. What Happens With `15`?

Let's trace:

```ruby
get_user_preferences(15)
```

### Step 1: Decimal → Binary

```ruby
15.to_s(2)
# => "1111"
```

### Step 2: Split

```ruby
"1111".split("")
# => ["1", "1", "1", "1"]
```

### Step 3: Reverse

```ruby
["1", "1", "1", "1"].reverse
# => ["1", "1", "1", "1"]
```

### Step 4: Find active bits

```text
index 0 → 2⁰ = 1
index 1 → 2¹ = 2
index 2 → 2² = 4
index 3 → 2³ = 8
```

Result:

```ruby
[1, 2, 4, 8]
```

### Step 5: Map to names

```ruby
[
  PREFERENCES[1],
  PREFERENCES[2],
  PREFERENCES[4],
  PREFERENCES[8]
]
```

Result:

```ruby
["sms", "whatsapp", "email", "call"]
```

Therefore:

```ruby
get_user_preferences(15)

# prints:
# ["sms", "whatsapp", "email", "call"]
```

---

# 10. Why Use Powers of 2?

The important property is that every preference occupies a unique **bit**.

```text
SMS       = 0001
WhatsApp  = 0010
Email     = 0100
Call      = 1000
```

Combining them:

```text
SMS + WhatsApp

0001
0010
----
0011

= 3
```

So:

```ruby
3
```

represents:

```text
SMS + WhatsApp
```

Similarly:

```text
SMS + Email

0001
0100
----
0101

= 5
```

Therefore:

```ruby
5
```

represents:

```text
SMS + Email
```

And:

```text
WhatsApp + Call

0010
1000
----
1010

= 10
```

So:

```ruby
10
```

represents:

```text
WhatsApp + Call
```

---

# 11. Examples

```ruby
get_user_preferences(1)
# => ["sms"]

get_user_preferences(2)
# => ["whatsapp"]

get_user_preferences(4)
# => ["email"]

get_user_preferences(8)
# => ["call"]

get_user_preferences(3)
# => ["sms", "whatsapp"]

get_user_preferences(5)
# => ["sms", "email"]

get_user_preferences(10)
# => ["whatsapp", "call"]

get_user_preferences(15)
# => ["sms", "whatsapp", "email", "call"]
```

---

# 12. A Simpler Ruby Version

The original code works, but Ruby's bitwise operators make this problem much easier to express.

Instead of converting the number to a binary string, we can check each flag directly:

```ruby
PREFERENCES = {
  1 => "sms",
  2 => "whatsapp",
  4 => "email",
  8 => "call"
}

def get_user_preferences(user_preferences)
  PREFERENCES.select do |value, _name|
    (user_preferences & value) != 0
  end.values
end

get_user_preferences(15)
# => ["sms", "whatsapp", "email", "call"]
```

---

# 13. Understanding `&`

The `&` operator performs a **bitwise AND**.

For example:

```text
user_preferences = 5

5 = 0101
```

Check SMS:

```text
5 & 1

0101
0001
----
0001

= 1
```

So SMS is enabled.

Check WhatsApp:

```text
5 & 2

0101
0010
----
0000

= 0
```

So WhatsApp is not enabled.

Check Email:

```text
5 & 4

0101
0100
----
0100

= 4
```

So Email is enabled.

Therefore:

```ruby
get_user_preferences(5)
# => ["sms", "email"]
```

---

# 14. Why Bitmasks Are Useful

Bitmasks allow multiple boolean settings to be stored in **one integer**.

Instead of storing:

```ruby
sms_enabled = true
whatsapp_enabled = false
email_enabled = true
call_enabled = false
```

you can store:

```ruby
preferences = 5
```

because:

```text
5 = 0101

SMS       → 1 → enabled
WhatsApp  → 0 → disabled
Email     → 1 → enabled
Call      → 0 → disabled
```

This technique is commonly called:

- **Bit flags**
- **Bitmask**
- **Bitwise flags**

---

# Quick Reference

```text
Preference    Value    Binary
--------------------------------
SMS             1      0001
WhatsApp        2      0010
Email           4      0100
Call            8      1000
```

Combined values:

```text
1  → SMS
2  → WhatsApp
4  → Email
8  → Call

3  → SMS + WhatsApp
5  → SMS + Email
6  → WhatsApp + Email
9  → SMS + Call
10 → WhatsApp + Call
12 → Email + Call
15 → SMS + WhatsApp + Email + Call
```

## Key Idea

> **Each preference gets its own binary bit.**

That allows one integer to represent multiple independent preferences.

```text
15
 ↓
1111
 ↓
┌───────┬───────┬───────┬───────┐
│ Call  │ Email │ Whats │  SMS  │
│   1   │   1   │   1   │   1   │
└───────┴───────┴───────┴───────┘
```