## Elasticsearch Upgrade Summary

**System:** Docker-compose based Nextcloud + Elasticsearch setup (oberdocker)

**Upgrade Path:** elasticsearch:8.9.1 → 8.19.x → 9.2.4 (completed)

**Steps Performed:**

1. **Pre-upgrade checks:**
   - Verified cluster health: `curl localhost:9200/_cluster/health`
   - Listed indices: `curl "localhost:9200/_cat/indices?v"`
   - Confirmed nextcloud index: 396 documents, ~28MB
   - Checked deprecation warnings: `curl localhost:9200/_migration/deprecations?pretty`

2. **Backup:**
   ```bash
   docker stop oberdocker_elasticsearch_1
   sudo tar -czf elasticsearch-backup-8.19-YYYYMMDD.tar.gz /var/lib/docker/volumes/oberdocker_elasticsearch*/
   docker start oberdocker_elasticsearch_1
   ```

3. **Upgrade process (8.x → 9.x):**
   ```bash
   cd /home/oberuser/oberdocker
   # Edit docker-compose.yml - change elasticsearch:8.19.x to elasticsearch:9.2.4
   docker stop oberdocker_elasticsearch_1
   docker rm oberdocker_elasticsearch_1
   docker-compose pull
   docker-compose up -d
   ```

4. **Post-upgrade verification:**
   - Check version: `curl localhost:9200` (confirmed 9.2.4)
   - Verify indices intact: `curl "localhost:9200/_cat/indices?v"`
   - Test search: `curl "localhost:9200/nextcloud/_search?pretty"`
   - Test Nextcloud search functionality via UI
   - Monitor logs: `docker logs oberdocker_elasticsearch_1`

**Notes:**
- Single-node cluster = yellow status is normal (unassigned replica shards expected)
- Main index: `nextcloud` with 396 documents
- Test index: `read_me` (empty, can be deleted)
- Major version upgrade (8→9) successful - indices migrated automatically
- No reindexing required for this upgrade

**Rollback:** Restore from backup tarball and revert docker-compose.yml image version if needed

**Current Status:** Running elasticsearch:9.2.4 successfully
