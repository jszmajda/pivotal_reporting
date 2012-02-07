## Pivotal Reporting

This is a simple ruby script I use to produce a weekly report on what us
developers have been up to.

### Usage

    bundle exec ./bin/pivotal_report.rb -t <pivotal token> -p <project id>

Where `<pivotal token>` is your pivotal API token available at the end
of [your profile page][1], and `<project id>` is the id of your project (I
just look at the URL when I'm examining the project, like in
https://www.pivotaltracker.com/projects/**12345**, 12345 is the project
id.)


### Output

You'll get four sections: Discussion Items, Story Bullets, PPU Table,
and In Progress. The first two are specific to my team's process (we
pre- and post- estimate stories to improve our estimation process and
create a feedback loop for production tokens). The PPU Table and In
Progress sections are probably generically useful.

#### The PPU Table

PPU is *Points Per User*. Here's an example table:

                | Elvis | Frank | Ron | Bob | Bill | Reggie |  Total || Feature | Bug | Chore |
    client      |     0 |     5 |   9 |   0 |    8 |      3 |     25 ||      22 |   0 |     3 |
    fires       |     0 |     1 |   1 |   0 |    0 |      0 |      2 ||       0 |   1 |     1 |
    operations  |    10 |     1 |   0 |   5 |    0 |      1 |     17 ||      12 |   2 |     3 |
    ops:intake  |     2 |     0 |   0 |   0 |    0 |      0 |      2 ||       2 |   0 |     0 |
    performance |     0 |     0 |   0 |   0 |    1 |      0 |      1 ||       1 |   0 |     0 |
    servers     |     0 |     0 |   0 |   2 |    0 |      0 |      2 ||       0 |   0 |     2 |
    sourcing    |     0 |     0 |   0 |   1 |    0 |      0 |      1 ||       0 |   0 |     1 |
    ------------+-------+-------+-----+-----+------+--------+--------++---------+-----+-------+
    Total       |    12 |     7 |  10 |   8 |    9 |      4 |     50 ||      37 |   3 |    10 |

This table is about the stories in the most recently completed
iteration. The first Y axis is the unique labels in the iteration, the X
axis is first the developers who contributed and then a breakdown of
story type. The numbers in the body of the table are the points
allocated to that combination of label and either developer or story
type. There are of course a pair of totals columns.

This table is useful in our process of both planning for development
capacity and monitoring usage. I take this report and add a column for
planned points by label and over/under by label. We then use this
analysis to discuss the tech department's future planning and modify our
plans and expectations.

#### In Progress

This is just a sum of the points allocated to stories that are currently
started, delivered, or unaccepted. I use this to show the current state
of projects in progress during my iteration planning meeting.

[1]: https://www.pivotaltracker.com/profile
