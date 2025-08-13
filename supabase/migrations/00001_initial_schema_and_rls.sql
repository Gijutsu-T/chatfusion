-- User Profiles
create policy "Users can view all profiles" on public.user_profiles for
select
  to authenticated using (true);

create policy "Users can update their own profile" on public.user_profiles
for update
  to authenticated using (auth.uid () = id);

-- Servers
create policy "Users can view servers they are members of" on public.servers for
select
  to authenticated using (
    id in (
      select
        server_id
      from
        public.server_members
      where
        user_id = auth.uid ()
    )
  );

create policy "Users can create servers" on public.servers for insert to authenticated
with
  check (true);

create policy "Server owners can update their servers" on public.servers
for update
  to authenticated using (auth.uid () = owner_id)
with
  check (auth.uid () = owner_id);

create policy "Server owners can delete their servers" on public.servers for delete to authenticated using (auth.uid () = owner_id);

-- Server Members
create policy "Users can view members in servers they belong to" on public.server_members for
select
  to authenticated using (
    server_id in (
      select
        server_id
      from
        public.server_members
      where
        user_id = auth.uid ()
    )
  );

create policy "Users can join servers" on public.server_members for insert to authenticated
with
  check (auth.uid () = user_id);

create policy "Users can leave servers" on public.server_members for delete to authenticated using (auth.uid () = user_id);

-- Channels
create policy "Users can view channels in servers they are members of" on public.channels for
select
  to authenticated using (
    server_id in (
      select
        server_id
      from
        public.server_members
      where
        user_id = auth.uid ()
    )
  );

create policy "Server owners can create channels" on public.channels for insert to authenticated
with
  check (
    auth.uid () in (
      select
        owner_id
      from
        public.servers
      where
        id = server_id
    )
  );

create policy "Server owners can update channels" on public.channels
for update
  to authenticated using (
    auth.uid () in (
      select
        owner_id
      from
        public.servers
      where
        id = server_id
    )
  )
with
  check (
    auth.uid () in (
      select
        owner_id
      from
        public.servers
      where
        id = server_id
    )
  );

create policy "Server owners can delete channels" on public.channels for delete to authenticated using (
  auth.uid () in (
    select
      owner_id
    from
      public.servers
    where
      id = server_id
  )
);

-- Messages
create policy "Users can view messages in channels they have access to" on public.messages for
select
  to authenticated using (
    channel_id in (
      select
        c.id
      from
        public.channels c
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

create policy "Users can send messages in channels they have access to" on public.messages for insert to authenticated
with
  check (
    auth.uid () = sender_id
    and channel_id in (
      select
        c.id
      from
        public.channels c
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

create policy "Users can update their own messages" on public.messages
for update
  to authenticated using (auth.uid () = sender_id)
with
  check (auth.uid () = sender_id);

create policy "Users can delete their own messages" on public.messages for delete to authenticated using (auth.uid () = sender_id);

-- Direct Messages
create policy "Users can view direct messages they are part of" on public.direct_messages for
select
  to authenticated using (
    auth.uid () = sender_id
    or auth.uid () = receiver_id
  );

create policy "Users can send direct messages" on public.direct_messages for insert to authenticated
with
  check (auth.uid () = sender_id);

create policy "Users can update their own direct messages" on public.direct_messages
for update
  to authenticated using (auth.uid () = sender_id)
with
  check (auth.uid () = sender_id);

create policy "Users can delete their own direct messages" on public.direct_messages for delete to authenticated using (auth.uid () = sender_id);

-- Message Reactions
create policy "Users can view reactions in channels they have access to" on public.message_reactions for
select
  to authenticated using (
    message_id in (
      select
        m.id
      from
        public.messages m
        join public.channels c on m.channel_id = c.id
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

create policy "Users can add reactions to messages they can see" on public.message_reactions for insert to authenticated
with
  check (
    auth.uid () = user_id
    and message_id in (
      select
        m.id
      from
        public.messages m
        join public.channels c on m.channel_id = c.id
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

create policy "Users can delete their own reactions" on public.message_reactions for delete to authenticated using (auth.uid () = user_id);

-- Calls
create policy "Users can view calls they are part of" on public.calls for
select
  to authenticated using (
    channel_id in (
      select
        c.id
      from
        public.channels c
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

create policy "Users can start calls in channels they have access to" on public.calls for insert to authenticated
with
  check (
    channel_id in (
      select
        c.id
      from
        public.channels c
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

-- Call Participants
create policy "Users can see participants in calls they are in" on public.call_participants for
select
  to authenticated using (
    call_id in (
      select
        cl.id
      from
        public.calls cl
        join public.channels c on cl.channel_id = c.id
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

create policy "Users can join calls in channels they have access to" on public.call_participants for insert to authenticated
with
  check (
    auth.uid () = user_id
    and call_id in (
      select
        cl.id
      from
        public.calls cl
        join public.channels c on cl.channel_id = c.id
        join public.server_members sm on c.server_id = sm.server_id
      where
        sm.user_id = auth.uid ()
    )
  );

create policy "Users can leave calls" on public.call_participants for delete to authenticated using (auth.uid () = user_id);