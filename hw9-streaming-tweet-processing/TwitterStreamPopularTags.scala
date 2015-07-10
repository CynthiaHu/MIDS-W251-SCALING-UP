/* TwitterStreamPopularTags.scala */
package edu.berkeley.ds.w251.streaming.twitter

import org.apache.spark.streaming.Seconds
import org.apache.spark.streaming.StreamingContext
import org.apache.spark.streaming.StreamingContext._
import org.apache.spark.SparkContext._
import org.apache.spark.streaming.twitter._
import org.apache.spark.SparkConf
import twitter4j._

import com.typesafe.config.ConfigFactory
import com.typesafe.config.Config

object TwitterStreamPopularTags {

    def main(args: Array[String]) {
        // load app config
        val conf:Config = ConfigFactory.load()
        // get twitter credentials
        val consumerKey = conf.getString("consumerKey")
        val consumerSecret = conf.getString("consumerSecret")
        val accessToken = conf.getString("accessToken")
        val accessTokenSecret = conf.getString("accessTokenSecret")
        // read app parameters
	val batchDuration = conf.getString("batch_duration").toInt
        val slidingWindow = conf.getString("sliding_window").toInt
        val topN = conf.getString("top_n").toInt

        //println("consumer key = " + consumerKey)
        //println("consumer secret = " + consumerSecret)
        //println("access token = " + accessToken)
        //println("access token secret = " + accessTokenSecret)
        println("batch duration = " + batchDuration)
        println("sliding window = " + slidingWindow)
        println("top n tweets = " + topN)

        // set the system properties so that Twitter4j library used by 
        // twitter stream an use them to generat OAuth credentials
        System.setProperty("twitter4j.oauth.consumerKey", consumerKey)
        System.setProperty("twitter4j.oauth.consumerSecret", consumerSecret)
        System.setProperty("twitter4j.oauth.accessToken", accessToken)
        System.setProperty("twitter4j.oauth.accessTokenSecret", accessTokenSecret)

        // main entry point for spark Streaming functionality
        val sparkConf = new SparkConf().setAppName("TwitterStreamPopularTags").setMaster("local[4]")
        val ssc = new StreamingContext(sparkConf, Seconds(batchDuration))
        // using spark stream context to create a stream of tweets
        val stream = TwitterUtils.createStream(ssc, None)    

        // custom class to access tweet elements
        case class TweetStreamData(topic: String, uAuthors:String, uMentioned:Array[String])

        // monster to get unique hashtags with tweet user authors and twitter user mentioned
        val tweets = stream.map(
            tweetStatus => {
                val topic       = tweetStatus.getText().split(" ").filter(_.startsWith("#"))
                val u_author    = tweetStatus.getUser.getScreenName()
                val uMentioned  = tweetStatus.getUserMentionEntities().map(_.getScreenName).toArray
                (topic, uMentioned, u_author)
            }).flatMap{ case (topic, uMentioned, uAuthors) => topic.map( topic => TweetStreamData(topic, uAuthors, uMentioned) )}

        // count topics aggregated by the tweeted users and the users mentioned
        // sort by topic counts and pick top N
        tweets.window(Seconds(slidingWindow)).foreachRDD(rdd => {
            val topList = rdd
                              .map{case (tweet) => (tweet.topic, (1, Set(tweet.uAuthors), tweet.uMentioned))}
                              .reduceByKey((x, y) => (x._1 + y._1, x._2 ++ y._2, x._3 ++ y._3))
                              .sortBy({case (_, (count, _, _)) => count}, ascending = false)
                              .take(topN)

            println("\nPopular %d topics in last %s seconds".format(topN, slidingWindow))	

            topList.foreach { case (topic, (count, uAuthors, uMentioned)) => {
                 println(s"topic $topic ($count total)")
                 println(s"  users (${uAuthors.size} total)\n    " + uAuthors.mkString(", "))
                 println(s"  mentions (${uMentioned.size} total)\n    " + (if (uMentioned.nonEmpty) uMentioned.mkString(", ")))
              }
            }
        })
	
        // terminate stream context
        sys.ShutdownHookThread {
              println("stopping spark streaming application")
              ssc.stop(true, true)
              println("application stopped")
        }

        // start spark streaming application
        ssc.start()
        println("starting spark streaming application to stream tweets")
        // wait for user input to terminate spark streaming application
        ssc.awaitTermination()
        ssc.stop(stopSparkContext = true, stopGracefully = true)

        }
    }