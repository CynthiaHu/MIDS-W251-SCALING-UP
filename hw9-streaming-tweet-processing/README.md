# W251 - HW9 - Streaming Tweet Processing
#### Rajesh Thallam

## Task

Continually process incoming Twitter stream data for the duration of at least 30 minutes and output a summary of data collected. During processing, program should collect and aggregate tweets over a user-configurable sampling duration up to at least a few minutes. The number of top most popular topics, n, to aggregate at each sampling interval must be configurable as well. From tweets gathered during sampling periods determine:

- The top n most frequently-occurring hash tags among all tweets during the sampling period (tweets containing these tags pick out 'popular' topics)

- The account names of users who authored tweets on popular topics in the period

- The account names of users who were mentioned in popular tweets or by popular people

## How to Run

Scripts are located on the spark standalone instance provided with the submission.

```
Path: /root/hw9/scripts
Jar file location: /root/hw9/scripts/target/scala-2.10/twitterstreampopulartags-project_2.10-1.0.jar
```

Application specific parameters can be configured by modifying `application.conf` file in the resources `src/main/resources/application.conf`

```
consumerKey=XXXXXXXXXXXXXXXXXXXXXXXXX
consumerSecret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
accessToken=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
accessTokenSecret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
batch_duration=30
sliding_window=1800
top_n=10
master_url="local[4]"
```

Program can be launched using below

```
cd /root/hw9/scripts
sbt package run
```

## Implementation Approach

1. Using application parameters Tweet stream was ingested using Spark stream context with a sampling duration of 30sec (*configurable*)

2. Tweet stream is flat mapped into a custom class `TweetStreamData(topic, uAuthors, uMentioned)`

    - *topic*: hashtag filtered starting with '#'
    - *uAuthors*: array of screen name of the users who tweeted
    - *uMentions*: array of screen name of the users who were mentioned by the tweet users

3. For the analysis, topics were accumulated and aggregated with associated tweet users and mentions using `foldByKey` operation over a sliding window of 30min (*configurable*). 

4. Top 10 topics are taken after sorting the results from foldByKey over a window. The resultant are directed to the output with the list of tweet users and mentions.  

## Results
Output with popular topics, tweeted users and mentioned users with a sampling duration of 30s and a sliding window of 30min is available [here](results_30min.out).

## Challenges Faced
- Originally analysis was done with *reduceByKeyAndWindow* but this required multiple count tuples to be created and then joined
- Due to standalone instance of Spark, I could not measure performance over the cluster

## References
[Real Time Processing with Spark Streaming](http://ampcamp.berkeley.edu/3/exercises/realtime-processing-with-spark-streaming.html)
[Advance Analytics with Spark](https://www.safaribooksonline.com/library/view/advanced-analytics-with/9781491912751/ch02.html#DataCleansingAggregate)
