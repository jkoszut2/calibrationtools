import os
import glob
# Add r in front of path if path contains whitespace
path = r"/users/demo/desktop/sample data"
os.chdir(path)
retval = os.getcwd()
print("INFO: Current working directory: %s" % retval)
print("INFO: Log files in directory:")
for file in glob.glob("*.csv"):
    print(file)
prompt = ("USER INPUT: Merge all files? (Y/N)> ")
user_input = input(prompt)
if user_input == "Y" or user_input == "y" \
   or user_input == "Yes" or user_input == "yes":
    prompt = ("USER INPUT: Enter name of new log file: >")
    user_input = input(prompt)
    outputFile = (user_input + '.csv')
    print("INFO: Concatenating all log files.")
    logFiles = glob.glob("*.csv")
    header_saved = False
    outTime = 0
    with open(outputFile, 'w') as fout:
        for indivLog in logFiles:
            with open(indivLog) as Log:
                header = ""
                for i in range(0, 18):
                    header = header + next(Log)
                if not header_saved:
                    fout.write(header)
                    header_saved = True
                for line in Log:
                    # Create cumulative time stamp
                    # Split line
                    splitLine = line.split(',')
                    # Get first entry in line
                    time = splitLine[0]
                    # Convert string to float
                    time = float(time.strip('"'))
                    # Add previous file's last time stamp
                    time = time + outTime
                    # Convert to string
                    time = '"' + str(time) + '"'
                    # Overwrite time stamp in extracted line
                    splitLine[0] = time
                    # Correct line format
                    line2 = ','.join(splitLine)
                    # Write line to new csv file
                    fout.write(line2)
                lastLine = line2.split(',')
                outTime = lastLine[0]
                outTime = float(outTime.strip('"'))
            print("INFO: Finished concatenating %s" % indivLog)
            print("INFO: Current time stamp: %s sec" % outTime)
    print("INFO: Success! New log file created.")
