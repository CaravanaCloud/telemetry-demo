package telemo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class Heartbeat implements Serializable {
    static final String serverUUID = UUID.randomUUID().toString();

    String sourceUUID;
    String sourceIP;
    BigDecimal lat;
    BigDecimal lng;
    LocalDateTime createTime;
    LocalDateTime acceptTime;
    String displayColor;
    Integer batteryLevel;

    @Override
    public String toString() {
        return JSON.stringify(this);
    }

    public String getSourceUUID() {
        return sourceUUID;
    }

    public String getSourceIP() {
        return sourceIP;
    }

    public BigDecimal getLat() {
        return lat;
    }

    public BigDecimal getLng() {
        return lng;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public static String getServerUUID() {
        return serverUUID;
    }

    public LocalDateTime getAcceptTime() {
        return acceptTime;
    }

    public String getDisplayColor() {
        return displayColor;
    }

    public Integer getBatteryLevel() {
        return batteryLevel;
    }

    public static Heartbeat of() {
        return new Heartbeat(){{
            sourceUUID = serverUUID;
            lat = BigDecimal.ZERO;
            lng = BigDecimal.ZERO;
            sourceIP = "0.0.0.0";
            createTime = LocalDateTime.now();
            acceptTime = LocalDateTime.now();
            displayColor = "#000000";
            batteryLevel = 100;
        }};
    }

}
