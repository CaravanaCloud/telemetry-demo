package telemo;

import io.quarkus.test.junit.NativeImageTest;

@NativeImageTest
public class NativeHeartbeatResourceIT extends HeartbeatResourceTest {

    // Execute the same tests but in native mode.
}