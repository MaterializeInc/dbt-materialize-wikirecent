## dbt + Materialize

Welcome! This repo walks you through a basic [dbt](https://www.getdbt.com/) project that uses 
[Materialize](https://materialize.com/docs/) as its data warehouse and a [Wikipedia change feed](https://stream.wikimedia.org/?doc)
as its data. 

*Note*: the [`dbt-materialize`](https://github.com/MaterializeInc/dbt-materialize) adapter used for this
project is still a work in progress! If you hit a snag along the way, please open an issue or submit a PR.

### Basic setup
To get everything you need to run dbt with Materialize locally, do the following:
1. Git clone this repo.

1. Git clone the [`dbt-materialize` adapter repo](https://github.com/MaterializeInc/dbt-materialize).

1. Create a new Python virtual environment on your machine. Activate that environment,
   and install the following:
    ```nofmt
    pip install dbt
    pip install [../relative/path/to/dbt-materialize]
    ```

1. Replace or add the following profile to your `~/.dbt/profiles.yml` file:
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

1. Spin up a local Materialize instance on port `6875`, [instructions here](https://materialize.com/quickstart/).

Once you've completed these steps, you're ready to run dbt with Materialize!

### Creating models from Wikipedia data

In this project, we're going to use [dbt models](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/)
to create materialized views of a Wikipedia change feed. 

*Note*: A version of this demo where each view is manually created can be [found here](https://materialize.com/quickstart/)
in the "Create a real-time stream" section.

To create our dbt models, follow these steps:

1. Open a shell and run the following command to stream Wikipedia edit events into local file:
   ```nofmt
   while true; do
     curl --max-time 9999999 -N https://stream.wikimedia.org/v2/stream/recentchange >> wikirecent
   done
   ```
   Note the absolute path of the location of `wikirecent`, which we’ll need in the next step.

1. [Connect to your running Materialize instance](https://materialize.com/docs/connect/cli/)
   from your shell. Once you've connected, [create a source](https://materialize.com/docs/sql/create-source/text-file/#main)
   using your `wikirecent` file from the last step:
   ```nofmt
   CREATE SOURCE wikirecent
   FROM FILE '[path to wikirecent]' WITH (tail = true)
   FORMAT REGEX '^data: (?P<data>.*)';
   ```   
   
1. Verify that your source was created by running the following in your shell:
    ```nofmt
   > SHOW SOURCES;
       name
   ------------
    wikirecent
   
   > SHOW COLUMNS FROM wikirecent; 
       name    | nullable | type
   ------------+----------+------
    data       | t        | text
    mz_line_no | f        | int8
   ```

1. Create your materialized views using dbt. In your shell, navigate to where you cloned this project
   on your local machine. Once there, run the following [dbt commands](https://docs.getdbt.com/reference/dbt-commands/)
   from your Python virtual environment:
   ```nofmt
   dbt compile
   dbt run
   ```
   
   `dbt compile` generates executable SQL from our model files, which can be found in the `models` directory
   of this project. `dbt run` executes the compiled SQL files against the target database, creating
   our materialized views.
   
   Note: If you haven't set up your Python environment with `dbt` and the `dbt-materialize` adapter,
   please revisit the [basic setup](#basic-setup) above.
   
1. Verify that `dbt run` created your materialized views by running the following:
   ```nofmt
   > SHOW VIEWS;
        name
   ---------------
    recentchanges
    top10
    useredits
   ```
   
Congratulations! You've just used dbt to create materialized views in Materialize. Now that everything is
set up, you can interactively query each of the views you just created. For example:
   ```nofmt
   > SELECT * FROM top10;
        user      | changes
   ---------------+---------
    Fæ            |   10834
    Sic19         |    7970
    Lockal        |   10450
    Akbarali      |    9631
    SuccuBot      |    8862
    Merge bot     |    4019
    Edoderoobot   |    3953
    Sarri.greek   |    3900
    BotMultichill |    4391
    SchlurcherBot |    8005
   (10 rows)
   ```

At this point, you might be wondering -- what do each of these views mean? To learn a bit more, let's generate
and view their documentation using dbt. From your Python virtual environment, run:
   ```nofmt
   dbt docs generate
   dbt docs serve
   ```
   
`dbt docs generate` generates this project's documentation website. `dbt docs serve` makes those 
docs available at http://localhost:8080. 

Once the local docs site is available, click into `materialize_wikirecent` and `models` to inspect
the documentation of each.

### Resources:
- Learn more about Materialize [in the docs](https://materialize.com/docs/)
- Join Materialize's [chat](https://materializecommunity.slack.com/join/shared_invite/zt-jjwe1t45-klG9k7V7xibdtqA6bcFpyQ#/) on Slack for live discussions and support
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Join dbt's [chat](http://slack.getdbt.com/) on Slack for live discussions and support