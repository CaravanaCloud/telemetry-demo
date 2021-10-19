package telemo;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.util.JSONPObject;
import org.jboss.resteasy.spi.HttpRequest;
import software.amazon.awssdk.services.ses.SesClient;
import software.amazon.awssdk.services.ses.SesClientBuilder;
import software.amazon.awssdk.services.ses.model.*;

import javax.enterprise.context.ApplicationScoped;
import javax.json.JsonObject;
import javax.transaction.Transactional;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import java.time.LocalDateTime;
import java.util.UUID;

import static javax.ws.rs.core.MediaType.APPLICATION_JSON;
import static javax.ws.rs.core.MediaType.TEXT_PLAIN;

@ApplicationScoped
@Path("/notify")
public class NotificationResource {
    @Path("mail")
    @POST
    @Consumes(APPLICATION_JSON)
    @Produces(TEXT_PLAIN)
    public String postMail(JsonNode body) {
        if (body == null) throw new IllegalArgumentException();

        var from = body.get("from").textValue();
        var to = body.get("to").textValue();
        var subject = body.get("subject").textValue();
        var message = body.get("text").textValue();
        if (! isValid(to, from, subject, message))
            throw new IllegalArgumentException();

        return sendEmail(from, to, subject, message);
    }

    private String sendEmail(String from, String to, String subject, String content) {
        var ses = SesClient.builder().build();
        var to_dest = Destination.builder().toAddresses(to).build();
        var message = Message.builder()
                .subject(Content.builder().data(subject).build())
                .body(Body.builder().text(
                                Content.builder().data(content).build()
                        ).build()
                ).build();
        var sendEmailReq = SendEmailRequest.builder()
                    .source(from)
                    .destination(to_dest)
                    .message(message)
                    .build();
        var sendEmailResp = ses.sendEmail(sendEmailReq);
        var sendEmailRespStr = sendEmailResp.toString();
        return sendEmailRespStr;
    }



    private boolean isValid(String to, String from, String subject, String message) {
        System.out.println("-------");
        System.out.println(from);
        System.out.println(to);
        System.out.println(subject);
        System.out.println(message);
        return to != null
                && from != null
                && subject != null
                && message != null;
    }

}
