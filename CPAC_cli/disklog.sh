# written by eric bridgeford

while true; do
    echo "$(du -s $1 | awk '{print $1}')"
    sleep 30
done

