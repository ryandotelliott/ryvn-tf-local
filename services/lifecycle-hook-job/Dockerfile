FROM busybox:1.36

ENV SUCCESS=true

CMD ["sh", "-c", "echo \"SUCCESS=${SUCCESS}\"; case \"${SUCCESS}\" in true|TRUE|1|yes|YES) exit 0 ;; *) exit 1 ;; esac"]
