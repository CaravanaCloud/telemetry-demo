package simulations

import scala.concurrent.duration._
import io.gatling.core.Predef._
import io.gatling.core.session.Expression
import io.gatling.http.Predef._
import org.slf4j.LoggerFactory
import org.slf4j.LoggerFactory
import ch.qos.logback.classic.{Level, LoggerContext}

class TelemoSimulation extends Simulation {
  val logLevel = "WARN"
  val context = LoggerFactory.getILoggerFactory.asInstanceOf[LoggerContext]
  context.getLogger("io.gatling.http").setLevel(Level.valueOf(logLevel))

  var baseUrl = sys.env.getOrElse("GATLING_BASE_URL", "http://localhost:8080")
  var acceptHdr = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  var doNotTrackHdr = "1"
  var userAgentHdr = "Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0"

  val httpProtocol = http
    .baseUrl(baseUrl)
    .acceptHeader(acceptHdr)
    .doNotTrackHeader(doNotTrackHdr)
    .userAgentHeader(userAgentHdr)

  val post_hb_body =
    """{
      "sourceUUID": "33333333-3333-3333-33333333333333333",
      "sourceIP": "0.0.0.0",
      "lat": 0,
      "lng": 0,
      "createTime": "2021-04-19T12:30:08.526699",
      "displayColor": "#000000",
      "batteryLevel": 100
    }"""

  val get_fibo = http("get_fibo").get("/api/algos/fibo").queryParam("x","10")

  val get_hb = http("get_hb").get("/api/hb")

  val post_hb = http("post_hb").post("/api/hb")
    .header("content-type","application/json")
    .body(StringBody(post_hb_body))

  val get_stats = http("get_stats").get("/api/hb/stats")

  val scn = scenario("Telemetry Scenario")
    .exec(get_fibo)
    .exec(get_hb)
    .exec(post_hb)
    .exec(get_stats)


  setUp(
    scn.inject(
      //DEBUG atOnceUsers(1)
      incrementUsersPerSec(5)
        .times(5)
        .eachLevelLasting(5.minutes)
        .separatedByRampsLasting(1.minutes)
        .startingFrom(1)
    )
  ).protocols(httpProtocol)
}