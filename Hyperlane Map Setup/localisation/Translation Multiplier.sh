file="hms_l_english.yml"
name="${file%.*}"
ext="${file##*.}"

for i in {"braz_por","french","german","japanese","korean","polish","russian","simp_chinese","spanish"}; do cp "$file" "${file//english/${i}}"; done

