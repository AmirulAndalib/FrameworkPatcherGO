get_framework_patch_url() {
    FWPATCH_GH_URL="https://api.github.com/repos/changhuapeng/FrameworkPatch/releases/latest"
    FILE="classes.dex"
    regex="s#^[[:blank:]]*\"browser_download_url\":[[:blank:]]*\"(https.*$FILE)\"#\1#p"
    wget --no-check-certificate -qO- "$FWPATCH_GH_URL" | sed -nE "$regex"
}

classes_path_to_dex() {
    path="$1"
    regex='s@^.+\/(smali(_classes[[:digit:]]+)*)\/.*\.smali$@\1@p'
    classes="$(echo "$path" | sed -nE "$regex")"
    case "$classes" in
        "smali" )
            echo "classes.dex"
            ;;
        *)
            echo "$(echo "$classes" | cut -d'_' -f2).dex"
            ;;
    esac
}

get_context_val() {
    code="$1"
    context="$(echo "$code" | grep "# Landroid/content/Context;")"
    if [ -n "$context" ]; then
        context="$(echo "$context" | sed -e 's/^[[:blank:]]*//')"
        context="$(echo "$context" | cut -d',' -f1 | cut -d' ' -f2)"
    else
        context="$(echo "$code" | grep "Landroid/content/Context;->" | head -n1)"
        if [ -n "$context" ]; then
            regex='s/^.+\{(.[[:digit:]]+)\}$/\1/p'
            context="$(echo "$context" | cut -d',' -f1)"
            context="$(echo "$context" | sed -nE "$regex")"
        else
            context="$(echo "$code" | grep "attach(Landroid/content/Context;)" | tail -n1)"
            if [ -n "$context" ]; then
                context="$(echo "$context" | cut -d',' -f1-2)"
                regex='s/^.+\{.*,[[:blank:]](.[[:digit:]]+)\}$/\1/p'
                context="$(echo "$context" | sed -nE "$regex")"
            else
                context="$(echo "$code" | grep "Landroid/content/Context;)" | tail -n1)"
                if [ -n "$context" ]; then
                    context="$(echo "$context" | cut -d',' -f1)"
                    regex='s/^.+\{(.[[:digit:]]+)\}$/\1/p'
                    context="$(echo "$context" | sed -nE "$regex")"
                fi
            fi
        fi
    fi
    echo "$context"
}
