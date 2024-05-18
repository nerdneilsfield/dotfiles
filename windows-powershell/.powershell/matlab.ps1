function matlabnw {
    if (Get-Command matlab -ErrorAction SilentlyContinue) {
        matlab -nodesktop -nosplash
    } else {
        Write-Error "Command not found: matlab" 
    }
}

function matlabnwr {
    if (Get-Command matlab -ErrorAction SilentlyContinue) {
        matlab -nosplash -nodesktop -r "run('$args[0]'); exit;"
    } else {
        Write-Error "Command not found: matlab" 
    }
}