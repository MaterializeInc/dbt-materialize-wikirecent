## dbt + Materialize

Welcome! This repo walks you through a basic [dbt](https://www.getdbt.com/) project that uses 
[Materialize](https://materialize.com/docs/) as its data warehouse and a [Wikipedia change feed](https://stream.wikimedia.org/?doc)
as its data. 

We intend to improve this project and its documentation over time, so PRs are welcome!

### Basic setup
To get everything you need to run dbt with Materialize locally, work through the following steps:
1. Git clone this repo.

1. Git clone the [`dbt-materialize` adapter repo](https://github.com/MaterializeInc/dbt-materialize).

1. Create a new local Python virtual environment. Once you've activated that virtualenv,
   run:
    - `pip install dbt`
    - `pip install [../relative/path/to/dbt-materialize]`
    
1. Run Materialize on port `6875`, [installation instructions here](https://materialize.com/quickstart/).

1. Replace or add the following to your `~/.dbt/profiles.yml` file:
```nofmt
default:
  outputs:

    dev:
      type: materialize
      threads: 1
      host: localhost
      port: 6875
      user: user
      pass: pass
      dbname: materialize
      schema: public

  target: dev
```

At this point, you should be set up to run dbt with Materialize. Next, we'll introduce the
Wikipedia data in order to create meaningful and interesting views.

### Creating models

In this project, we're going to create [dbt models](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/)
on top of a Wikipedia change feed. (A different version of this Materialize demo over the same data can be
[found here](https://materialize.com/quickstart/) in the "Create a real-time stream" section).

First, let's set up a stream of Wikipedia's recent changes, and write all of these changes to a
file. From your shell, run this command:
```nofmt
while true; do
  curl --max-time 9999999 -N https://stream.wikimedia.org/v2/stream/recentchange >> wikirecent
done
```
Note the absolute path of the location where you write `wikirecent`, which we’ll need in the next step.

Once you have this stream, create a Materialize source via `psql`:
```
CREATE SOURCE wikirecent
FROM FILE '[path to wikirecent]' WITH (tail = true)
FORMAT REGEX '^data: (?P<data>.*)';
```

You can verify that your source was correctly created in Materialize with `SHOW SOURCES` or
`SHOW COLUMNS FROM wikirecent`.

Now, instead of following the rest of the traditional `wikirecent` demo steps, we are going to
create the materialized views using dbt models instead. This repo provides you with the three
models you need, each with their own file in the `models` directory: `recentchanges`, `useredits`,
and `top10`. 

Navigate to this directory in your shell. Then, run the following [dbt commands](https://docs.getdbt.com/reference/dbt-commands/):
```nofmt
dbt compile
dbt build
```

You'll notice that `dbt build` creates your materialized views for you! Returning to `psql`, you
should be able to query each of the views that you just created. For example, the following query will
return the top 10 Wikipedia editors since you started your stream:
```sql
SELECT * FROM top10;
```

If you open `models/schema.yml`, you will be able to see the definitions of each of the models.
Additionally, you will see that we've added a few tests. To run these tests, run:
```nofmt
dbt test
```

### Resources:
- Learn more about Materialize [in the docs](https://materialize.com/docs/)
- Join Materialize's [chat](https://materializecommunity.slack.com/join/shared_invite/zt-jjwe1t45-klG9k7V7xibdtqA6bcFpyQ#/)
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Join dbt's [chat](http://slack.getdbt.com/) on Slack for live discussions and support