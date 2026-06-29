file="roci_l_english.yml"
name="${file%.*}"
ext="${file##*.}"

for i in {"braz_por","french","german","polish","russian","spanish"}; do cp "$file" "${file//english/${i}}.${ext}"; done

