# Adding/Removing Users on the JCC
The intended purpose of the JCC is to provide an in-house, high performance computing environment for UAH students, faculty, and researchers. As such, JCC administrators will regularly need to add a large number of users at one time and set up user environments for all of them in order to grant JCC access to a UAH course, UAH instructors, or a UAH research group, and the same can be said for removing a large number of users to revoke JCC access to those groups.

On other systems, this is a *very* tedious process. However, the JCC Development Team has provided a fast and easy way to add or remove several users via the **account management** package within the JCC's proprietary software suite (courtesy of JCC developer Satyo Wasistho).

The **account management** software package is located in the **/home/jcccluster/JCCdev/account_management** directory on the JCC's master node and is only accessible to JCC administrators. This package contains two scripts, **addusers.sh** and **removeusers.sh**.

## Requirements
To set up or delete a large number of user accounts, you only need a list of usernames. Store this list in a text file. The file can be named anything. For the purposes of this guide, we will refer to the file as **usernames.txt**.

**usernames.txt format**
```
saw0037
sfr0009
jct0025
mdo0002
wpb0003
```
## Adding Users
With this file in your current directory, you can now set up the listed users on the JCC. Simply pass the **usernames.txt** file into the **addusers.sh** script as shown below.

``
sudo bash addusers.sh usernames.txt
``

This will add the listed user accounts as **standard users**. Do this if the group you are giving JCC access to is of students taking a UAH course.

For non-student users, you can specify a Linux group to add the user accounts to. The JCC already has common groups set up for this purpose. The groups are as follows:
|Group   |Sudo?|
|--------|-----|
|Users   |No   |
|Admin   |Yes  |
|Staff   |Yes  |
|Research|No   |
To add user accounts under one of these groups, simply add a group parameter when running the **addusers.sh** script as shown below.

``
sudo bash addusers.sh <groupname> usernames.txt
``

All user accounts are given the default password, "WelcomeToJCC". Users can change their password at any time using the **passwd** command. 
## Removing Users
To remove multiple users from the JCC, simply pass the **usernames.txt** file into the **removeusers.sh** script as shown below.

``
sudo bash removeusers.sh usernames.txt
``

With that, you now know how to easily add or remove several users on the JCC.
