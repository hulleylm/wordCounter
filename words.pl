#!/usr/bin/perl
# Author: Laura
# CGI Perl script: URL retrieval [perl03B]

# create new CGI perl object
use CGI qw(-utf-8 :all *table);
use LWP::Simple qw(get);
binmode(STDOUT, ":encoding(utf-8)");

$geturl = new CGI;

#start and name form
print $geturl->header;
print $geturl->start_html("Assignment1 - word counter");

#if a url has been entered, do this:
unless (!$geturl->param) {
  #get url from textfield and assign to $url
  $url = $geturl->param('URL');

  print h1 ("Information on URL:"), br(), "\n";
  print ("URL entered: $url"), br(), "\n";

  #check url exists
  if (head($url)) {
    print br(), "\nURL exists", br(), "\n";
    #Assign text at URL to string
    my $words = get($url);
    $words = uc $words;

    #check if string is all ASCII characters
    if ($words =~ /[^[:ascii:]]/) {
      print "\nThis text contains characters that are not ASCII -
      this could skew results\n";
      #remove all non-ascii characters
      $words =~ s/[^[:ascii:]]//g;

    } else {
      print "\nThis text consists of all ASCII characters\n";
    }

    print br(), "\nContent of URL: ", get($url), br(), "\n";

    #split the string by specified delimiters:
    #(anything between <...>) | (anything that is not a dash, 'word' character,
    #apostrophe or underscore) | (two or more dashes) | (two or more apostrophes)
    #changed them all to commas first as otherwise it classes an empty value as
    #a word.
    #ToDo: split by '- or  -'
    $words =~ s/<[^>]*>|[^-\w'_]|(-{2,})|('{2,})/,/g;
    my @strings = (split /,+/, $words);



    #count word occurrences
    $numOfWords = 0;
    foreach my $word (@strings) {
      #do not count any words that:
      #(start with an apostrophe not followed by a letter) | (start with a non-
      #letter) | (end with an apostrophe not preceeded by an s) | (end with
      #a character that isn't alphanumeric)
      if ($word =~ /^'(?=[^A-Z])|^[^A-Z]|([^s])(?='$)|([^A-Z0-9]$)/) {
        $count{$word};
      }
      else {
        $count{$word} ++;
        $numOfWords++;
      }
    }

    print ("Total number of words: $numOfWords"), br(), "\n";

    if ($numOfWords >= 1) {
      print h1 ("Word occurrences:"), br(), "\n";
      #output results in two tables, max 10 rows each
      print start_table({-border=>1});
      print caption ("most common words");
      $rowCounter = 1;
      foreach $word (reverse sort {$count{$a} <=> $count{$b}} keys %count) {
        if ($rowCounter <= 10) {
          print Tr(td([$word, $count{$word}]));
          $rowCounter++;
        }
        else {
          last;
        }
      }

      print end_table;

      print start_table({-border=>1});
      print caption ("least common words");
      $rowCounter = 1;
      foreach $word (sort {$count{$a} <=> $count{$b}} keys %count) {
        if ($rowCounter <= 10) {
          print Tr(td([$word, $count{$word}]));
          $rowCounter++;
        }
        else {
          last;
        }
      }
    }

    print end_table;

  #if head(url) returns false, output that there is no array there
  } else {
    print "url does not exist";
  }

#if no url has been entered yet, show the form
} else {
  print $geturl->h1("URL word counter");
  print $geturl->startform;
	print $geturl->textfield(-name=>'URL',
		-default=>'Enter the url here...',
		-size=>200);
	print $geturl->br(), "\n";
	print $geturl->submit(-value=>'Process');
	print $geturl->endform;
}

print $geturl->end_html;
