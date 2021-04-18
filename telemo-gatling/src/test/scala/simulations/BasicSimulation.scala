package simulations

import scala.concurrent.duration._
import io.gatling.core.Predef._
import io.gatling.core.session.Expression
import io.gatling.http.Predef._

class BasicSimulation extends Simulation { // 3
  var baseUrl = sys.env.getOrElse("GATLING_BASE_URL", "http://localhost:8080")
  var acceptHdr = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  var doNotTrackHdr = "1"
  var userAgentHdr = "Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0"

  val httpProtocol = http
    .baseUrl(baseUrl)
    .acceptHeader(acceptHdr)
    .doNotTrackHeader(doNotTrackHdr)
    .userAgentHeader(userAgentHdr)

  val get_hb = http("get_hb").get("/api/hb")
  val get_stats = http("get_stats").get("/api/hb/stats")

  val scn = scenario("Telemetry Simulation")
    .exec(get_hb)
    .exec(get_stats)
    .pause(5)

  setUp(
    scn.inject(
      incrementUsersPerSec(20)
        .times(5)
        .eachLevelLasting(30.seconds)
        .startingFrom(10)
    )
  ).protocols(httpProtocol)
}