# CHIQUI.to

This is a small rails application to shorten URL's _ala_ bit.ly, tinyURL, etc. The most interesting part of this is really the algorithm to generate such small URL's. The first thinig that would come to mind is to hash the URL, however, there are several problems with that approach, and the most important is that most hash algorithms produce rather large strings, even MD5.

**What does chiquito means?**

Chiquito means _"small one"_ in spanish. Depending on where you are in a spanish-speaking country it may be used for different things but it essentially means small or tiny. In Mexico it is often used to call kids and toddlers alike, hence the silly design of the frontend.

## Running locally

This app uses Ruby 2.6, besides that:

 - Rename the included `env.example` to `.env.development` file and change your settings accordingly
 - If you plan tu run tests create/copy `env.example` to `.env.test` and set its values
 - Make sure you have PostgreSQL and REDIS installed and running locally
 - You will probably need GCC and friends to build certain native gems (like nokogiri) so make sure you have your development tools installed

Then just do the usual dance:

```
bundle install
```

Prepare the database:

```
rails db:drop db:create db:migrate
```

If you want to have some test data at the beginning:

```
rails db:seed
```

And simply run it:

```bash
rails server
```

## Running with docker

If you don't want to hassle with setting a local dev environment you can just fire up a docker instance of the app:

 - Rename the included `env.example` to `.env`
 - Change the settings there. They _should_ work right out of the box but you can make adjustments (like the postgres user, password etc.) but its not necessary

Once you have the settings on place simply run the following:

```
docker-compose up --build
```

That should run the application, however, you still need to run migrations to create the database, you can do so by running a one-time container and run the migration command:

```bash
docker-compose run web rake db:migrate
```

And if you want to create some test data:

```bash
docker-compose run web rake db:seed
```

### Notes on running with Docker

If you run this application with Docker please make sure that you are not running the same services on the local machine or at least in the same ports, for instance, another rails application under TCP port **3000**, another instance of Postgres in port **5432**, Redis server in **6379** etc, otherwise the container will stop complaining on ports already being used. Remember Docker binds those containerized services ports into the host machine network.

Also, if you want to access a rails console to do some testing or manual work you can do so by executing a rails command to the running container like this:

```bash
docker exec -it chiquito_web_1 /bin/bash
```

Once there, you will have a **bash** session within the container pointing the current working directory to the actual `/app` folder so you can just run:

```bash
bundle exec rails console
```

And you should be good to go.

Also, there are volumes (as in disks) created so whatever data you input in the application and in the database will be persisted even if you stop the containers, unless you prune the system or remove the containers.

## Running tests

Prepare the test database:

```
rake db:test:prepare RAILS_ENV=test
```

Run tests:

```
bundle exec rspec
```

## The shortening algorithm

So doing a little reasearch what seems to be the smartest thing (and what most shorteners seem to do) is to use a so called [Bijective Function](https://en.wikipedia.org/wiki/Bijection) which _"essentially"_ means that you have a one-to-one corresponce of elements between two sets effectively having a uniqueness attribute.

But the most important thing here is that we want to keep it short. The way to do it is using a base62 encoding set. Why is it base62 and not base64? Well, for vanity really, if you understand the [Base64 encoding](https://en.wikipedia.org/wiki/Base64#Base64_table) principle you'll know that there are 64 possible characters that you can use, hence the 64; you can use lowercase letters from the alphabet, which makes up for 26 in total, considering that you use ASCII (e.g. no special characters like ñ) and then you have another 26 for uppercase letters, then, 10 more for unique number digits, which is 0 to 9 and finally you can use two special characters: "+" and "/" and thats where the 62 comes from, we don't use them because they are not URL safe as in, they will break your URLs.

You can go read the above links but the easiest way to explain the algorithm is this: you have your base62 characters on a matrix/array, each corresponding to an index, so each index has a character, say our alphabet is this:

| Index      | Character |
| ----------- | ----------- |
| 00 | a |
| 01 | b |
| 02 | c |
| 03 | d |
| 04 | e |
...
| 27 | A |
| 28 | B |
| 29 | C |
| 30 | D |
| 31 | E |
...
| 53 | 0 |
| 54 | 1 |
| 55 | 2 |
| 56 | 3 |
| 57 | 4 |
| 58 | 5 |
| 59 | 6 |
| 60 | 7 |
| 61 | 8 |
| 62 | 9 |

I'm skipping all characters but you get the idea. The way that it is easier to implement this for our purposes is to use the auto-generated ID from the database, Why? Because it is unique, the database engine is already making sure of that, so less work for us. Once you create a record and you get your unique ID you will start using it as an index for our table above in base62.

**But, what happens if we have an ID higher than 62, wouldn't we run out of mappings?**

Not quite. We can do combinations with the map in a way that we can have a finite number of them as much as we want to keep the URL short. Say that we have the ID `1`, which maps to the character `b`, so once we reach the end of this map for a number what we do is we start mixing the next one in the set, that means, we add up a character to the resulting encoding, so `62` would be `ba` because we reached the end of the initial map _(remember indices in computing start at 0)_ and `63` would be  `bc`, `64` would be `bd` and so on. So, we take the character and start doing [permutations](https://en.wikipedia.org/wiki/Permutation) with the next one, that is the pattern.

The easiest way to understand it is this: each time that our number reaches a multiple of 62 (which is the entire set) we will do a permutation of the next following character in that set with each of the characters in the set:

| Number      | Permutation |
| ----------- | ----------- |
| 62 (62*1) | ba |
| 124 (62*2) | ca |
| 186 (62*3) | da |
| 248 (62*4) | ea |

So, you can see the pattern there. These encoded strings will start to grow in size of course, the larger the number, the more characters we need to eventually store it, for instance, for `500,000` we'll get `cgeG`.

That's it for now!



