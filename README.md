# ENUM
ENUM is collection of great subdomain enumeration tools combined together to generate one list of unique subdomains. I use this personally to Automate the usage of tools I ran separately/manually. The current subdomain wordlist is a combination of Justin Haddix's 'all.txt', and all of the DNS Discovery text files from SecLists. There are currently 2,784,098 unique entries. If MassDNS is taking a while, make a sandwich.

Credits to the following projects and their contributors:

- https://github.com/nahamsec/lazyrecon
- https://github.com/OWASP/Amass
- https://github.com/blechschmidt/massdns
- https://github.com/aboul3la/Sublist3r
- https://github.com/danielmiessler/SecLists

### Usage
```
./enum.sh -d "example.com" -o "outputfile.txt"
```
![Alt text](https://github.com/Dec0y-jb/enum/blob/master/enum.png?raw=true)

# Dependencies
All dependencies are included with ENUM (aside from python). You can use the current releases of the tools listed above which are included, or you can modify the path variables as shown below. Please note that the default binary for 'Amass' is the amd64 version; Please point to the i386 version if necessary (not included).

### Path variables in 'enum.sh':
```
# path definitions
enumpath="${0%/*}"
masspath=$enumpath/massdns
sublisterpath=$enumpath/Sublist3r
amasspath=$enumpath/amass_v3.0.27_linux_amd64
```

### Todo
- [ ] Accept domains from a file
- [ ] Add exclusion arguments
