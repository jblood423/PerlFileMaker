#!/usr/bin/perl

#intended to run system wide
#move to /usr/bin
#chown root:root makeperl
#root ownership allows writing to log



#filename to create


#secure the path
$ENV{'PATH'} = '/bin:/usr/bin';

#secure the environmental variables
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};


if( lc $ARGV[0] eq lc "log"){
	print "enter search term: ";
	chomp($term = <STDIN>);
	
#	open(LOGFILE, "< /tmp/perl_log.txt") or die "cannot read from log\n");
	system("grep $term /tmp/perl_log.txt");
	exit;
}



#open the log
open(LOGFILE, ">> /tmp/perl_log.txt") or die "cannot write to log\n";
print LOGFILE (localtime)." $username "."opened log file\n";




$filename = $ARGV[0];


#actual username of person running script
my $username = getpwuid($<);



#if the file exists, warn of clobbering data
if(-e "./$filename"){

	print LOGFILE (localtime)." $username "."duplicate file detected\n";
	print "file exists, continue? y/n ";
	chomp($cont = <STDIN>); 

	if($cont eq "n"){
	print LOGFILE (localtime)." $username "."program terminated by user\n";
	die "Terminated by user\n";	 
	}
	print LOGFILE (localtime)." $username "."overwriting $filename\n";
}	

#prevent tainted data from being passed
if( $filename =~ /^([-\@\w.]+)$/){
	$filename = $1;

#open the file to be created
open(MYFILE, '>', $1) or die "Cannot read from $filename - $!";
print LOGFILE (localtime)." $username "."created and opened $filename\n";

#write the content to the created file
print MYFILE "#!/usr/bin/perl";

#if user specifies warnings, add flag
if($ARGV[1]){
	print MYFILE " -w\n";
}
else{ print MYFILE "\n";}

print LOGFILE (localtime)." $username "."closing new perl file $1\n";
close(MYFILE);

#update permissions
print LOGFILE (localtime)." $username "."updating permissions to 775 on $1\n";
system("chmod 775 $1");
system("chown $username:$username $1");
}
else{ die "Bad data in '$filename'"};

close(LOGFILE);
