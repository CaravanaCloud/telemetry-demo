package telemo;

import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.persistence.EntityManager;

@ApplicationScoped
public class HeartbeatService {
    @Inject
    EntityManager em;

    public List<Heartbeat> findAll() {
        return em
            .createQuery("SELECT hb FROM Heartbeat hb", Heartbeat.class)
            .getResultList();
    }

    public void persist(Heartbeat hb) {
        em.persist(hb);
    }
}
