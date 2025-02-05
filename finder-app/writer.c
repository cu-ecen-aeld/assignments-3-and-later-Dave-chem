#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

//Assignment 2 - Dave_chem
//Write a C application “writer” (finder-app/writer.c)  which can be used as an alternative to the “writer.sh” test script created in the above-mentioned assignment1 and using File IO in the new writer.c.  See the Assignment 1 requirements for the writer.sh test script and these additional instructions:

//One difference from the write.sh instructions in Assignment 1:  You do not need to make your "writer" utility create directories which do not exist.  You can assume the directory is created by the caller.

//Setup syslog logging for your utility using the LOG_USER facility.

//Use the syslog capability to write a message “Writing <string> to <file>” where <string> is the text string written to file (second argument) and <file> is the file created by the script.  This should be written with LOG_DEBUG level.

//Use the syslog capability to log any unexpected errors with LOG_ERR level.

//So I'd like to use open(), write(), close() for file I/O. And syslog() for structured logging.

    // Main function
    //argc means argument count
    //char *argv[] means Array of strings representing each argument passed via the command line.
    // Open syslog with LOG_USER facility
    //"writer": Identifier for log messages.
    //LOG_PID: Ensures process ID (PID) is included in log messages.
    //LOG_USER: Specifies the facility (category) under which the log messages are classified.
    
int main(int argc, char *argv[]) {

    openlog("writer", LOG_PID, LOG_USER);

// Check for correct number of arguments. Need 3 here.
//argv[0]: The program name.
//argv[1]: The file path.
//argv[2]: The string to write into the file.
//If incorrect arguments are provided:
//syslog(LOG_ERR, "..."): Logs an error message at the LOG_ERR (error) level.
//fprintf(stderr, "..."): Prints an error message to the standard error (stderr).
//closelog(): Closes the system log connection.
//return 1;: Exits the program with a non-zero status, indicating failure.
    
    if (argc != 3) {
        syslog(LOG_ERR, "Error: Invalid number of arguments. Usage: writer <file> <string>");
        fprintf(stderr, "Usage: %s <file> <string>\n", argv[0]);
        closelog();
        return 1;
    }

//writefile stores the file path.
//writestr stores the text to be written to the file.

    char *writefile = argv[1];
    char *writestr = argv[2];

// Open file for writing (truncate if exists, create if not)
//open() is a system call that opens the file.
//O_WRONLY: Open the file in write-only mode.
//O_CREAT: Create the file if it does not exist.
//O_TRUNC: If the file exists, truncate (clear) its content before writing.
//0644: File permission mode:
//6 (owner: read & write),
//4 (group: read),
//4 (others: read).

    int fd = open(writefile, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    
//If open() fails (fd == -1):
//syslog(LOG_ERR, "..."): Logs an error.
//perror("Error opening file"): Prints a descriptive system error.
//closelog();: Closes syslog.
//return 1;: Exits the program.

    if (fd == -1) {
        syslog(LOG_ERR, "Error: Could not open file %s", writefile);
        perror("Error opening file");
        closelog();
        return 1;
    }

//Write string to file
//ssize_t bytes_written → Stores the number of bytes written.
//write(fd, writestr, strlen(writestr)) →Writes writestr to the file.
//strlen(writestr) → Gets the length of writestr to determine how many bytes to write.
//bytes_written == -1 → If writing fails, handle the error.
//syslog(LOG_ERR, "Error: ...") → Logs the error.
//perror("Error writing to file") → Prints the error message.
//close(fd); → Closes the file.
//return 1; → Exits with an error.

    ssize_t bytes_written = write(fd, writestr, strlen(writestr));
    if (bytes_written == -1) {
        syslog(LOG_ERR, "Error: Could not write to file %s", writefile);
        perror("Error writing to file");
        close(fd);
        closelog();
        return 1;
    }

    // Log success message

    syslog(LOG_DEBUG, "Writing '%s' to '%s'", writestr, writefile);

    // Close file and syslog
    close(fd);
    closelog();
    
    //Returning Success
    return 0;
}

