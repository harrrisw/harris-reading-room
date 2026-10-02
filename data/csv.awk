# CSV codec owned by the data layer. Handles commas and doubled quotes.
# Application fields cannot contain newlines or tabs, keeping TSV pipes simple.
function decode(line, a,    i,c,n,quoted,value) {
    n=1; quoted=0; value=""
    for (i=1;i<=length(line);i++) {
        c=substr(line,i,1)
        if(c=="\"") {
            if(quoted && substr(line,i+1,1)=="\"") { value=value "\""; i++ }
            else quoted=!quoted
        } else if(c=="," && !quoted) { a[n++]=value; value="" }
        else value=value c
    }
    a[n]=value
    return n
}
function encode(value) { gsub(/"/,"\"\"",value); return "\"" value "\"" }
function key(t,a) { return tolower(t) SUBSEP tolower(a) }
BEGIN {
    FS=OFS="\t"
    op=ENVIRON["DB_OP"]; title=ENVIRON["DB_TITLE"]; author=ENVIRON["DB_AUTHOR"]
    target=key(title,author); found=0
}
NR==1 { if(op=="status" || op=="rating") print $0; next }
{
    sub(/\r$/, "")
    if(decode($0,f)!=7) { print "Invalid CSV row " NR > "/dev/stderr"; invalid=1; exit 2 }
    match_book=(key(f[1],f[2])==target)
    if(match_book) found=1
    if(op=="exists") next
    if(op=="list" || (op=="search" && index(tolower(f[1] " " f[2] " " f[3] " " f[4]),tolower(ENVIRON["DB_QUERY"])))) {
        print f[1],f[2],f[3],f[4],f[5],f[6],f[7]
    }
    if(op=="status" || op=="rating") {
        if(match_book) f[op=="status" ? 4 : 5]=ENVIRON["DB_VALUE"]
        for(i=1;i<=7;i++) printf "%s%s",encode(f[i]),(i==7 ? "\n" : ",")
    }
}
END {
    if(invalid) exit 2
    if((op=="exists" || op=="status" || op=="rating") && !found) exit 1
}
