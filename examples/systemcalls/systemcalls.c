#include "systemcalls.h"
#include <stdlib.h>
#include <stdarg.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

/**
 * Executes a command using the system() function.
 * @param cmd The command to execute.
 * @return true if the command executed successfully, false otherwise.
 */
bool do_system(const char *cmd)
{
    if (cmd == NULL) { // Check if the command string is NULL
        return false;
    }
    
    int ret = system(cmd); // Execute the command using system()
    return (ret != -1 && WIFEXITED(ret) && WEXITSTATUS(ret) == 0); // Check if execution was successful
}

/**
 * Executes a command using fork() and execv().
 * @param count The number of arguments.
 * @param ... A variable argument list containing the command and its arguments.
 * @return true if the command executed successfully, false otherwise.
 */
bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char *command[count + 1];
    for (int i = 0; i < count; i++) {
        command[i] = va_arg(args, char *); // Retrieve command arguments
    }
    command[count] = NULL; // Null-terminate the command array
    va_end(args);

    pid_t pid = fork(); // Create a new process
    if (pid == -1) { // Check if fork() failed
        return false;
    } else if (pid == 0) { // Child process
        execv(command[0], command); // Execute command
        _exit(EXIT_FAILURE); // Exit if execv fails
    }
    
    int status;
    if (waitpid(pid, &status, 0) == -1) { // Wait for the child process to complete
        return false;
    }
    
    return (WIFEXITED(status) && WEXITSTATUS(status) == 0); // Check if execution was successful
}

/**
 * Executes a command using fork() and execv(), redirecting output to a file.
 * @param outputfile The file to write command output.
 * @param count The number of arguments.
 * @param ... A variable argument list containing the command and its arguments.
 * @return true if the command executed successfully, false otherwise.
 */
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char *command[count + 1];
    for (int i = 0; i < count; i++) {
        command[i] = va_arg(args, char *); // Retrieve command arguments
    }
    command[count] = NULL; // Null-terminate the command array
    va_end(args);

    pid_t pid = fork(); // Create a new process
    if (pid == -1) { // Check if fork() failed
        return false;
    } else if (pid == 0) { // Child process
        int fd = open(outputfile, O_WRONLY | O_CREAT | O_TRUNC, 0644); // Open output file
        if (fd == -1) { // Check if file opening failed
            _exit(EXIT_FAILURE);
        }
        dup2(fd, STDOUT_FILENO); // Redirect standard output to file
        close(fd); // Close file descriptor
        execv(command[0], command); // Execute command
        _exit(EXIT_FAILURE); // Exit if execv fails
    }
    
    int status;
    if (waitpid(pid, &status, 0) == -1) { // Wait for the child process to complete
        return false;
    }
    
    return (WIFEXITED(status) && WEXITSTATUS(status) == 0); // Check if execution was successful
}

