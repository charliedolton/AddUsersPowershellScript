# AddUsersPowershellScript
A simple script to add AD-Users to a windows server.

In this example, the server would be for a student account system at a school. The idea is that you will be given a daily csv file (to be entered as an argument when executing the script) with all changes to the students' schedules. I chose to use the postal code attribute to keep track of the total number of classes for each student.

The VarDefinition file is included to make the script more usable to a different server. You would only have to edit that file to make the script work with a different domain.
