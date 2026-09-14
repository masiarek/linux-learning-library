#!/usr/bin/env bash
# What each POSIX character class holds in tr -- measured, not paraphrased.
#
# Every byte from \000 to \177 goes through `tr -dc '[:class:]'`, and whatever
# survives is printed. A run of digits, capitals, small letters or controls is
# written the way tr itself takes a range; punctuation is always spelled out.
# The runner pins LC_ALL=C, where GNU tr (Linux) and BSD tr (macOS) agree.
set -u

work=$(mktemp -d)
cd "$work" || exit 1

i=0
while [ "$i" -lt 128 ]; do
  printf "\\$(printf %03o "$i")"
  i=$((i + 1))
done > ascii.bin

# One byte as the table writes it: \t \n \v \f \r by name, a backslash doubled,
# any other control in octal, everything else as itself.
put() {
  case $1 in
    9) printf '\\t' ;; 10) printf '\\n' ;; 11) printf '\\v' ;;
    12) printf '\\f' ;; 13) printf '\\r' ;; 92) printf '\\\\' ;;
    *) if [ "$1" -lt 32 ] || [ "$1" -eq 127 ]; then printf '\\%03o' "$1"
       else printf "\\$(printf %03o "$1")"; fi ;;
  esac
}

# The run a byte may join. Anything that is not a control, a digit or a letter
# is a group of its own, so it never collapses into a range.
group() {
  if [ "$1" -lt 32 ]; then g=control
  elif [ "$1" -ge 48 ] && [ "$1" -le 57 ]; then g=digit
  elif [ "$1" -ge 65 ] && [ "$1" -le 90 ]; then g=capital
  elif [ "$1" -ge 97 ] && [ "$1" -le 122 ]; then g=small
  else g=byte$1
  fi
}

flush() {
  put "$start"
  if [ $((last - start)) -ge 2 ]; then printf '%s' -; put "$last"
  elif [ "$last" -ne "$start" ]; then put "$last"; fi
}

members() {
  start='' last='' run=''
  for o in $(tr -dc "[:$1:]" < ascii.bin | od -An -v -to1); do
    n=$((8#$o))
    group "$n"
    if [ -n "$start" ] && [ "$g" = "$run" ] && [ "$n" -eq $((last + 1)) ]; then
      last=$n
      continue
    fi
    [ -n "$start" ] && flush
    start=$n last=$n run=$g
  done
  [ -n "$start" ] && flush
}

echo 'class      bytes  members, of the 128 ASCII bytes'
for c in alnum alpha blank cntrl digit graph lower print punct space upper xdigit; do
  count=$(tr -dc "[:$c:]" < ascii.bin | wc -c)
  printf '[:%s:]%*s %4d   [' "$c" $((6 - ${#c})) '' $count
  members "$c"
  echo ']'
done

cd / && rm -rf "$work"
