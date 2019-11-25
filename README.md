# Doctolib Technical Test

Here is my project for Doctolib technical test.
I wrote a class method `Event.availaibilities("2018-05-12")` that returns 
the list of avalaible slots in the next seven days.

I have made some assumptions :
- slots last 30 minutes;
- appointments can be booked from the beginning of a slot only, ie, if slots are `9h-9h30-10h-10h30`, appointments can start at `9h, 9h30 and 10h`.

I have used `Guard` to run the tests automatically while changing the files and `Rubocop` to ensure code clarity.

## Setup

```
# install dependencies
bundle install

# database setup for SQLite
rails db:migrate
rails db:test:prepare
```

## Run test
```
rails test
```

## Run server
```
rails server
```
