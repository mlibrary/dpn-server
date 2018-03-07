# Overview

This file describes how the job queuing system for dpn-server works. The jobs are
separated into two main purposes: synchronization of registry entries from other
nodes, and replication.

# Synchronization

Synchronization is responsible for picking up changes in the DPN registry
(represented as ActiveRecord objects).

## At a Glance

This system rarely breaks in a way requiring user action.  This is done
purely via pulls over HTTPS. Total bandwidth use is negligble.

## Details

Files mostly live in `lib/client/sync`

The schedule has one sync job per entity type per node.

* We separate by entity type because dependencies are not automatically synced each time;
  instead, we expect another job to pick them up.
* We separate by node so that failure in syncing from one node does not infect another.

All sync jobs are designed to be idempotent. As you probably deduced from the above,
failures are expected.  In the resque job queue, it is always safe to clear all
failed sync jobs.

Repeatedly seeing the same failure of the same entity-node job indicates a problem.
These problems always result from either an issue at the other node, or us not yet
performing a manual remediation. We try to never perform manual remediations.


Jobs only request new information since the last run. More specifically, since the
start time of the last successful (exception-free) run.  These times are stored on
RunTime objects (`app/models/run_time`), with the name of the RunTime corresponding
1-to-1 with the entity-node unique pair.

# Replication

Replciation is responsible for downloading and processing bags from other nodes
into our local storage.

## At a Glance

DPN bag sizes are huge, generally 50GB or more, up to terabyte sizes. This means that
jobs take a long time to complete. Furthermore, there are not great tools for gaining
any visibility into the jobs' activity. This complicates determining if something has hung.

## Details

Replication requests, represented internally as ReplicationTransfer entities, are the starting
place for the replication process. These are updated via the synchronization process. The node
that created the request is also the node that wants us to copy the bag; the copy of the
entity in their registry is authoritative. No party is authoritative for the contents of the bag
itself.

The overall process is broken into the following steps, which we'll go over:

1. retrieval
2. unpack
3. fixity
4. validation
5. received notify
6. storage
7. stored notify

There is a corresponding job and queue for each of these steps. These are never
manually enqueued, even in debugging scenarios. Instead, in both normal and
manual operation, by a corresponding scheduler job.

### Scheduler Jobs

The inner workings of these jobs are out of scope of this document. The important
point is that they can be enqueued idemptotently from the resque schedule interface.
It's always safe to run one of these jobs; they have no state, not even a last run
time.

### Replication Flows and Attempts

The entire process per replication request (*not* per bag) is managed by entities of
the ActiveRecord class ReplicationFlow. The primary purpose of the ReplicationFlow
is to serve as an anchor point for the various \*Attempt objects.

When a scheduler spawns one of its corresponding jobs, it does so by creating an
attempt object to track within Rails the job that is running in resque. For example,
every retrieval job belongs to a RetrievalAttempt.  This applies for all seven of the
steps. This is important for a few reasons:

* It allows schedules to not spawn a duplicate job
* It allows us to retry the same replication flow step up to a certain limit
  (5 at time of writing).
* They serve as a place to store encountered errors.

### Retrieval

Uses system rsync to download the bag. Recovers from interruptions and requeues.
This will be to the `download_temp` space.

### Unpack

Unpacks the tarball into the `download_temp` space.

### Fixity

Performs a sha256 checksum of the tag-manifest in the exploded bag.

### Validation

Validates the exploded bag in accordance with the bagit spec and DPN's extensions
of that spec. Chiefly, the time is spent performing sha256 checksums of every item
in the bag.

### Received Notification

Updates the remote registry entry with the result of the validation and fixity attempts.
Uses HTTPS.

This step can really only fail if the remote node is down. After this step, we'll not
queue any more jobs for this flow until the synchronization picks up the remote node's
update. They need to set a flag that tells us to actually preserve the bag.

This waiting can take seconds or days, and should be the first point of investigation
when a node claims they're waiting on us.

### Storage

Uses system rsync to copy the bag from `download_temp` to the pairtree structure, still
on `/dpnrepo`.  Deletes the temporary bag and tarball after successful completion as reported
by rsync.

### Stored Notify

Updates the remote registry entry with notification that we've fully preserved the bag. This
point is important to the SLA as it is the point at which we've agreed to responsibiilty for
the bag.

### Known Issues

1. The resque-pool process dies or is restarted. Currently, the jobs are not smart
   enough to detect this, so the corresponding, ongoing Attempt is never told of
   the failure. As such, no job is running, but the system believes there is a job
   running. This can be resolved by simply deleting the Attempt(s).
2. We run out of space on /dpnrepo. This usually causes ongoing jobs to fail, which
   is what we want. However, they'll all be requeued repeatedly until they've hit the
   max amount of failure limit.  After that, schedulers will skip them.
3. We don't automatically clean up data in `download_temp` from failed bags.

### Remediations

Typically, most problems can be resolved by the following step:

1. Clear the queue. This can be done by deleting the queue in the resque interface.
2. Kill the running jobs. For some this can be done like killing any other system task.
   Otherwise, you can always restart resque-pool.
3. Delete all of the failed and ongoing attempts for the job type from the rails console.
   For example,
   `RetrievalAttempt.ongoing.destroy_all; RetrievalAttempt.where(success: false).destroy_all`
   We lose some diagnostic information but it's not information we actually need.
4. Re-run the scheduler--the retrieval scheduler in our example--from the resque interface.

Don't delete successful attempts.


