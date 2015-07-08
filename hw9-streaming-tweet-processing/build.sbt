name := "TwitterStreamPopularTags Project"
version := "1.0"
scalaVersion := "2.10.4"

mergeStrategy in assembly <<= (mergeStrategy in assembly) { (old) =>
   {
    case PathList("META-INF", xs @ _*) => MergeStrategy.discard
    case x => MergeStrategy.first
   }
}

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.3.1"
libraryDependencies += "org.apache.spark" %% "spark-streaming" % "1.3.1"
libraryDependencies += "org.apache.spark" %% "spark-streaming-twitter" % "1.3.1"

libraryDependencies += "org.twitter4j" % "twitter4j-stream" % "3.0.3"
libraryDependencies += "org.twitter4j" % "twitter4j-core" % "3.0.3"

libraryDependencies += "com.typesafe" % "config" % "1.2.0"
resolvers += "Akka Repository" at "http://repo.akka.io/releases/"